# Build Vulnerability Impact Path Analyzer

This script analyzes  security vulnerability differences between two build versions of a software build. It identifies the impacted repository paths of artifacts and maps these impacted paths to their actual repository locations.


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


Note: The "Imapcted Paths" format is
``` 
<xrayBinarymanagerName>/<build-repo>/<build-name>/<artifact>/<impacted_path_within_the_artifact>
```

Example output:
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
   - `POST /ui/api/v1/xray/ui/security_info/diff`
   - Compares vulnerability difference  between two build versions extracting `data.all.added.issue.id`, `data.all.removed.issue.id`, and `data.all.changed.issue.id` from the response.
   - The standard Artifactory [Builds Diff](https://jfrog.com/help/r/jfrog-rest-apis/builds-diff) API provides only the 
    published artifacts , dependencies and components deferences between the build versions, necessitating the use of this Xray UI API.


2. [Build Summary](https://jfrog.com/help/r/xray-rest-apis/build-summary) API:
   - `GET /xray/api/v2/summary/build`
   - Retrieves detailed build information, including impact paths for the identified Xray issue.ids.
   - This step is essential to determine which artifacts are affected by the vulnerabilities.

Note:  The same vulnerability information can also be got from the [Get Build’s Scan Results](https://jfrog.com/help/r/xray-rest-apis/get-build-s-scan-results) API as well.

3. [Build Artifacts Search](https://jfrog.com/help/r/jfrog-rest-apis/build-artifacts-search) API:
   - `POST /artifactory/api/search/buildArtifacts`
   - Used to retrieve the repository locations of artifacts containing the vulnerabilities.
   - This mapping ensures that the impacted paths are correctly associated with their respective repositories.

This approach enables precise tracking of security vulnerabilities across different build versions, facilitating better risk assessment and mitigation.

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
Note:  The same vulnerability information can also be got from the [Get Build’s Scan Results](https://jfrog.com/help/r/xray-rest-apis/get-build-s-scan-results) API as well ( which is shown below as an example).

```
jf xr curl -XGET "/api/v2/ci/build/YOUR-BUILD-NAME/YOUR-BUILD-VERSION?projectKey=YOUR-PROJECT-KEY&include_vulnerabilities=true" \
--server-id=YOUR-JF_CLI_SERVER_ID | jq > get_builds_scan_results.json

Example:
jf xr curl -XGET "/api/v2/ci/build/cg-mvn-base-webgoat/2025-03-12_09-40-35?projectKey=cg-lab&include_vulnerabilities=true" \
--server-id=psazuse | jq > get_builds_scan_results.json
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