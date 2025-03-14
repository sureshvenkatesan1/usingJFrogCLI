import argparse
import json
import requests
from typing import Dict, List, Set
import sys

def get_auth_headers(access_token: str) -> Dict[str, str]:
    return {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }

def format_curl_command(method: str, url: str, headers: Dict[str, str], params: Dict = None, json_data: Dict = None) -> str:
    """Format the equivalent curl command for a request"""
    curl_parts = [f"curl -X {method} "]
    
    # Add headers with obfuscated access token
    for key, value in headers.items():
        if key.lower() == "authorization":
            # Use $MYTOKEN for Authorization header
            curl_parts.append(f"-H \"Authorization: Bearer $MYTOKEN\" ")
        elif key.lower() == "cookie" and "accesstoken" in value.lower():
            # Use $MYTOKEN for Cookie header with access token
            curl_parts.append(f"-H \"Cookie: __Host-REFRESHTOKEN=*;__Host-ACCESSTOKEN=$MYTOKEN\" ")
        else:
            # Use original value for other headers
            curl_parts.append(f"-H \"{key}: {value}\" ")
    
    # Add URL with query parameters if GET request
    if method == "GET" and params:
        query_string = "&".join([f"{k}={v}" for k, v in params.items()])
        curl_parts.append(f"'{url}?{query_string}'")
    else:
        curl_parts.append(f"'{url}'")
    
    # Add JSON body if POST request
    if method == "POST" and json_data:
        curl_parts.append("-d '")
        curl_parts.append(json.dumps(json_data, indent=2))
        curl_parts.append("'")
    
    return "".join(curl_parts)

def get_build_vulnerability_diff(base_url: str, access_token: str, build_name: str, 
                               old_build_number: str, new_build_number: str, build_repo: str, debug: bool = False) -> Dict:
    url = f"{base_url}/ui/api/v1/xray/ui/security_info/diff"
    
    payload = {
        "old": {
            "type": "build",
            "component_id": f"build://[{build_repo}]/{build_name}:{old_build_number}",
            "package_id": f"build://[{build_repo}]/{build_name}",
            "path": "",
            "version": old_build_number
        },
        "new": {
            "type": "build", 
            "component_id": f"build://[{build_repo}]/{build_name}:{new_build_number}",
            "package_id": f"build://[{build_repo}]/{build_name}",
            "path": "",
            "version": new_build_number
        }
    }

    headers = {
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest",
        "Accept": "*/*",
        "Cookie": f"__Host-REFRESHTOKEN=*;__Host-ACCESSTOKEN={access_token}"
    }

    if debug:
        print("\nDEBUG: Build Vulnerability Diff API Request:")
        print(format_curl_command("POST", url, headers, json_data=payload))

    response = requests.post(url, headers=headers, json=payload)
    response.raise_for_status()
    return response.json()

def get_build_summary(base_url: str, access_token: str, build_name: str, 
                     build_number: str, build_repo: str, debug: bool = False) -> Dict:
    url = f"{base_url}/xray/api/v2/summary/build"
    params = {
        "build_name": build_name,
        "build_number": build_number,
        "build_repo": build_repo
    }
    headers = get_auth_headers(access_token)

    if debug:
        print("\nDEBUG: Build Summary API Request:")
        print(format_curl_command("GET", url, headers, params=params))
    
    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()
    return response.json()

def get_build_artifacts(base_url: str, access_token: str, build_name: str,
                       build_number: str, build_repo: str, project: str, debug: bool = False) -> Dict:
    url = f"{base_url}/artifactory/api/search/buildArtifacts"
    
    payload = {
        "buildName": build_name,
        "buildNumber": build_number,
        "buildRepo": build_repo,
        "project": project
    }
    headers = get_auth_headers(access_token)

    if debug:
        print("\nDEBUG: Build Artifacts API Request:")
        print(format_curl_command("POST", url, headers, json_data=payload))
    
    response = requests.post(url, headers=headers, json=payload)
    response.raise_for_status()
    return response.json()

def get_impacted_paths(build_summary: Dict, debug: bool = False) -> Set[str]:
    impacted_paths = set()
    
    if debug:
        print("\nDEBUG: Inside get_impacted_paths")
        print(f"DEBUG: Build summary has 'issues': {'issues' in build_summary}")
        if 'issues' in build_summary:
            print(f"DEBUG: Number of issues: {len(build_summary['issues'])}")
            print(f"DEBUG: Type of build_summary['issues']: {type(build_summary['issues'])}")
    
    if "issues" in build_summary:
        # if debug:
        #     print(f"DEBUG: Raw issues list: {json.dumps(build_summary['issues'], indent=2)}")  # Pretty print

        for issue in build_summary["issues"]:
            if debug:
                print(f"\nDEBUG: Processing issue: {issue.get('issue_id')}")
                print(f"DEBUG: Has impact_path: {'impact_path' in issue}")
                if 'impact_path' in issue:
                    print(f"DEBUG: Impact paths: {issue['impact_path']}")

            if "impact_path" in issue and isinstance(issue["impact_path"], list):  # Ensure it's a list
                impacted_paths.update(issue["impact_path"])

    if debug:
        print(f"\nDEBUG: Total impacted paths found: {len(impacted_paths)}")
        for path in impacted_paths:
            print(f"DEBUG: Path: {path}")
            
    return impacted_paths

def get_artifact_name_from_path(path: str) -> str:
    """Extract artifact name from impact path
    Format: <xrayBInarymanagerName>/<build-repo>/<build-name>/<artifact>/<impacted_path_within_the_artifact>
    """
    parts = path.split('/')
    if len(parts) >= 4:  # Ensure we have enough parts
        return parts[3]  # Get the artifact name (4th component)
    return path.split('/')[-1]  # Fallback to last component if path format is unexpected

def get_artifact_name_from_uri(uri: str) -> str:
    """Extract artifact name from download URI"""
    return uri.split('/')[-1]

def main():
    parser = argparse.ArgumentParser(description='Get impacted repository paths from build vulnerability diff')
    parser.add_argument('--build-name', required=True, help='Name of the build')
    parser.add_argument('--build-number-old', required=True, help='Old build number')
    parser.add_argument('--build-number-new', required=True, help='New build number')
    parser.add_argument('--build-repo', required=True, help='Build repository')
    parser.add_argument('--project', required=True, help='Project name')
    parser.add_argument('--base-url', required=True, help='Artifactory base URL')
    parser.add_argument('--access-token', required=True, help='Access token')
    parser.add_argument('--debug', action='store_true', help='Enable debug output')

    args = parser.parse_args()

    try:
        # Get build vulnerability diff
        vuln_diff = get_build_vulnerability_diff(
            args.base_url, args.access_token, 
            args.build_name, args.build_number_old, args.build_number_new,
            args.build_repo, args.debug  # Pass debug flag
        )

        # Get issue IDs from different categories
        issue_ids = set()
        if "data" in vuln_diff and "all" in vuln_diff["data"]:
            for category in ["added", "removed", "changed"]:
                if category in vuln_diff["data"]["all"]:
                    for issue in vuln_diff["data"]["all"][category]:
                        if "issue" in issue and "id" in issue["issue"]:
                            issue_ids.add(issue["issue"]["id"])

        # Get build summaries
        old_summary = get_build_summary(
            args.base_url, args.access_token,
            args.build_name, args.build_number_old, args.build_repo, args.debug  # Pass debug flag
        )
        new_summary = get_build_summary(
            args.base_url, args.access_token,
            args.build_name, args.build_number_new, args.build_repo, args.debug  # Pass debug flag
        )

        # if args.debug:
        #     print("\nDEBUG: Old Build Summary:")
        #     print(json.dumps(old_summary, indent=2))
        #     print("\nDEBUG: New Build Summary:")
        #     print(json.dumps(new_summary, indent=2))

        # Get impacted paths
        old_paths = get_impacted_paths(old_summary, args.debug)
        new_paths = get_impacted_paths(new_summary, args.debug)
        all_paths = old_paths.union(new_paths)

        # Print unique impacted paths for each build
        print("\nOld Build Impacted Paths:")
        for path in sorted(old_paths):
            print(f"  {path}")
            
        print("\nNew Build Impacted Paths:")
        for path in sorted(new_paths):
            print(f"  {path}")

        # Get artifact repository paths
        old_artifacts = get_build_artifacts(
            args.base_url, args.access_token,
            args.build_name, args.build_number_old, args.build_repo, args.project, args.debug
        )
        new_artifacts = get_build_artifacts(
            args.base_url, args.access_token,
            args.build_name, args.build_number_new, args.build_repo, args.project, args.debug
        )

        if args.debug:
            print("\nDEBUG: Old Build Artifacts:")
            print(json.dumps(old_artifacts, indent=2))
            print("\nDEBUG: New Build Artifacts:")
            print(json.dumps(new_artifacts, indent=2))

        # Create maps of artifact names to their full URIs for each build
        old_artifact_uri_map = {}
        new_artifact_uri_map = {}
        
        for result in old_artifacts.get("results", []):
            if "downloadUri" in result:
                artifact_name = get_artifact_name_from_uri(result["downloadUri"])
                old_artifact_uri_map[artifact_name] = result["downloadUri"]
                
        for result in new_artifacts.get("results", []):
            if "downloadUri" in result:
                artifact_name = get_artifact_name_from_uri(result["downloadUri"])
                new_artifact_uri_map[artifact_name] = result["downloadUri"]

        if args.debug:
            print("\nDEBUG: Old Build Artifact URI map:")
            for name, uri in old_artifact_uri_map.items():
                print(f"  {name}: {uri}")
            print("\nDEBUG: New Build Artifact URI map:")
            for name, uri in new_artifact_uri_map.items():
                print(f"  {name}: {uri}")

        # Use a dict to track unique repository paths and their build info
        repo_paths_info = {}  # {repo_path: (build_name, build_number)}
        
        # Process old build paths
        for path in old_paths:
            artifact_name = get_artifact_name_from_path(path)
            if args.debug:
                print(f"\nDEBUG: Processing old build path: {path}")
                print(f"DEBUG: Path components: {path.split('/')}")
                print(f"DEBUG: Extracted artifact name: {artifact_name}")
                print(f"DEBUG: Found in old_artifact_uri_map: {artifact_name in old_artifact_uri_map}")
            
            if artifact_name in old_artifact_uri_map:
                repo_paths_info[old_artifact_uri_map[artifact_name]] = (args.build_name, args.build_number_old)
            elif args.debug:
                print(f"DEBUG: No matching repository path found for {artifact_name} in old build")

        # Process new build paths
        for path in new_paths:
            artifact_name = get_artifact_name_from_path(path)
            if args.debug:
                print(f"\nDEBUG: Processing new build path: {path}")
                print(f"DEBUG: Path components: {path.split('/')}")
                print(f"DEBUG: Extracted artifact name: {artifact_name}")
                print(f"DEBUG: Found in new_artifact_uri_map: {artifact_name in new_artifact_uri_map}")
            
            if artifact_name in new_artifact_uri_map:
                repo_paths_info[new_artifact_uri_map[artifact_name]] = (args.build_name, args.build_number_new)
            elif args.debug:
                print(f"DEBUG: No matching repository path found for {artifact_name} in new build")

        # Print final unique repository paths with their build info
        print("\nImpacted Repository Paths:")
        for repo_path in sorted(repo_paths_info.keys()):
            build_name, build_number = repo_paths_info[repo_path]
            print(f"{repo_path} (from build: {build_name}:{build_number})")

    except requests.exceptions.RequestException as e:
        print(f"Error making API request: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
