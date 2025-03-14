# Build Vulnerability Impact Path Analyzer

This script analyzes the security vulnerability differences between two builds and identifies the impacted repository paths of artifacts.

## Purpose

The script helps security teams and developers by:
1. Comparing vulnerabilities between two builds
2. Identifying which artifacts are impacted by security issues
3. Mapping the impacted paths to their actual repository locations
4. Showing which build version contains each impacted artifact

## Prerequisites

- Python 3.6+
- Required Python packages:
  ```bash
  pip install requests
  ```
- Access to JFrog Platform with:
  - Xray service enabled
  - Valid access token with permissions for:
    - Xray API access
    - Artifactory API access
    - Build info access

## Usage
```
bash
python get_impacted_path_artifacts_repo_paths_from_build_diff.py \
--build-name "your-build-name" \
--build-number-old "old-build-number" \
--build-number-new "new-build-number" \
--build-repo "build-info-repository" \
--project "project-name" \
--base-url "https://your-artifactory-instance" \
--access-token "your-access-token" \
[--debug]
```

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| --build-name | Yes | Name of the build to analyze |
| --build-number-old | Yes | Build number of the old/previous build |
| --build-number-new | Yes | Build number of the new/current build |
| --build-repo | Yes | Name of the build info repository |
| --project | Yes | Name of the project |
| --base-url | Yes | Base URL of your JFrog Platform instance |
| --access-token | Yes | Access token for authentication |
| --debug | No | Enable debug output for troubleshooting |

### Output

The script provides three sections of output:

1. Old Build Impacted Paths:
   - Lists all paths impacted by vulnerabilities in the old build

2. New Build Impacted Paths:
   - Lists all paths impacted by vulnerabilities in the new build

3. Impacted Repository Paths:
   - Shows the actual repository locations of impacted artifacts
   - Indicates which build version contains each artifact

Example output:
Note: The "Imapcted Paths" format is 
`<xrayBInarymanagerName>/<build-repo>/<build-name>/<artifact>/<impacted_path_within_the_artifact>`
```
Old Build Impacted Paths:
default/build-info/my-build/artifact1.jar/lib/vulnerable-lib.jar
default/build-info/my-build/artifact2.jar/lib/another-lib.jar

New Build Impacted Paths:
default/build-info/my-build/artifact3.jar/lib/vulnerable-lib.jar

Impacted Repository Paths:
https://artifactory/path/to/artifact1.jar (from build: my-build:1.0.0)
https://artifactory/path/to/artifact2.jar (from build: my-build:1.0.0)
https://artifactory/path/to/artifact3.jar (from build: my-build:2.0.0)
```

## API Endpoints Used

The script interacts with the following JFrog Platform APIs:

1. Build Vulnerability Diff API:
   - Compares security issues between two builds
   - `POST /ui/api/v1/xray/ui/security_info/diff`

2. [Build Summary](https://jfrog.com/help/r/xray-rest-apis/build-summary) API:
   - Gets detailed build information including impact paths
   - `GET /xray/api/v2/summary/build`

3. [Build Artifacts Search](https://jfrog.com/help/r/jfrog-rest-apis/build-artifacts-search) API:
   - Retrieves artifact repository locations
   - `POST /artifactory/api/search/buildArtifacts`

## Debugging

Use the `--debug` flag to see detailed information about:
- API requests being made
- Data processing steps
- Path extraction and matching logic
- Any issues encountered during execution

When using `--debug`, the script will print the equivalent curl commands for each API request:

1. Build Vulnerability Diff API:
```bash
curl -X POST -H "Content-Type: application/json" -H "X-Requested-With: XMLHttpRequest" -H "Accept: */*" \
-H "Cookie: __Host-REFRESHTOKEN=*;__Host-ACCESSTOKEN=$MYTOKEN" \
'https://your-artifactory-instance/ui/api/v1/xray/ui/security_info/diff' \
-d '{
  "old": {
    "type": "build",
    "component_id": "build://[build-repo]/build-name:old-build-number",
    "package_id": "build://[build-repo]/build-name",
    "path": "",
    "version": "old-build-number"
  },
  "new": {
    "type": "build",
    "component_id": "build://[build-repo]/build-name:new-build-number",
    "package_id": "build://[build-repo]/build-name",
    "path": "",
    "version": "new-build-number"
  }
}'
```

2. Build Summary API:
```bash
curl -X GET -H "Authorization: Bearer $MYTOKEN" -H "Content-Type: application/json" \
'https://your-artifactory-instance/xray/api/v2/summary/build?build_name=build-name&build_number=build-number&build_repo=build-repo'
```

3. Build Artifacts Search API:
```bash
curl -X POST -H "Authorization: Bearer $MYTOKEN" -H "Content-Type: application/json" \
'https://your-artifactory-instance/artifactory/api/search/buildArtifacts' \
-d '{
  "buildName": "build-name",
  "buildNumber": "build-number",
  "buildRepo": "build-repo",
  "project": "project-name"
}'
```

Note: The access token is obfuscated as `$MYTOKEN` in the debug output for security.

## Error Handling

The script handles common errors including:
- API request failures
- Authentication issues
- Invalid path formats
- Missing data in responses

Errors are logged to stderr with descriptive messages.