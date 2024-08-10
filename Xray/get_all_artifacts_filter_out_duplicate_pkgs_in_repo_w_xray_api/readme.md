
## Overview

The [get_all_artifacts_filter_out_duplicate_pkgs_in_repo_w_xray_api.py](get_all_artifacts_filter_out_duplicate_pkgs_in_repo_w_xray_api.py) script is designed to interact with JFrog 
Xray's [Scans List - Get Artifacts](https://jfrog.com/help/r/xray-rest-apis/scans-list-get-artifacts) REST 
API to retrieve a list of artifacts from a specified repository within your JFrog Artifactory instance. It filters out duplicate packages based on their `package_id` and saves the resulting list of unique artifacts into a JSON file.

## Features

- **Authentication:** Uses an access token for secure API requests.
- **Artifact Retrieval:** Fetches up to 1000 artifacts per request and handles pagination automatically.
- **Duplicate Filtering:** Ensures that only unique packages are included in the final output.
- **JSON Output:** Saves the retrieved artifact data in a structured JSON file.

## Requirements

- Python 3.x
- `requests` library (`pip install requests`)
- JFrog Artifactory account with API access

## Environment Variables

Before running the script, ensure the following environment variables are set:

- `ART_URL`: The base URL of your JFrog Artifactory instance (e.g., `https://yourcompany.jfrog.io`).
- `ACCESS_TOKEN`: The access token used to authenticate with the JFrog Xray API.
- `REPOSITORY_NAME`: The name of the repository from which to retrieve artifacts.

## Usage


1. **Set the Required Environment Variables**

   Make sure the environment variables `ART_URL`, `ACCESS_TOKEN`, and `REPOSITORY_NAME` are properly set:

   ```bash
   export ART_URL="https://yourcompany.jfrog.io"
   export ACCESS_TOKEN="your-access-token"
   export REPOSITORY_NAME="your-repository-name"
   ```

2. **Run the Script**

   Execute the script using Python:

   ```bash
   python get_all_artifacts_filter_out_duplicate_pkgs_in_repo.py
   ```

3. **Check the Output**

   The script will generate an `output.json` file in the current directory containing the list of unique artifacts from the specified repository.

## Example

```bash
export ART_URL="https://example.jfrog.io"
export ACCESS_TOKEN="eyJhbGciOiJIUzI1..."
export REPOSITORY_NAME="example-repo"

python get_all_artifacts_filter_out_duplicate_pkgs_in_repo.py
```

This will produce an `output.json` file like:

```json
[
    {
        "package_id": "pkg-1",
        "artifact_data": {
            "name": "artifact1",
            "version": "1.0.0",
            ...
        }
    },
    {
        "package_id": "pkg-2",
        "artifact_data": {
            "name": "artifact2",
            "version": "2.0.0",
            ...
        }
    }
]
```

## Troubleshooting

- **Missing Environment Variables**: If the script exits with a message about missing environment variables, ensure `ART_URL`, `ACCESS_TOKEN`, and `REPOSITORY_NAME` are correctly set.
- **Connection Issues**: Ensure that the `ART_URL` is correct and reachable from your network.

