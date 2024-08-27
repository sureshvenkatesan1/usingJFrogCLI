
# Fetch All Artifacts in a Repository using AQL with JFrog CLI

The [fetch_all_artifacts_in_repo_using_aql_paginate.py](fetch_all_artifacts_in_repo_using_aql_paginate.py) Python script fetches all artifacts in a specified JFrog 
Artifactory repository using an AQL query. The results 
are paginated and saved to a CSV file. The script leverages the JFrog CLI for executing the AQL queries.

## Prerequisites

- Python 3.x installed on your machine.
- JFrog CLI installed and configured with the necessary Artifactory server credentials.
- The repository from which artifacts need to be fetched must be accessible.


## Usage

To run the script, use the following command:

```bash
python fetch_all_artifacts_in_repo_using_aql_paginate.py --server_id <your-server-id> --repo_name <your-repo-name> --items_per_page <items-per-page> --output_file <output-file-path>
```

### Parameters

- `--server_id`: The server ID configured in JFrog CLI. This should correspond to the Artifactory server where the repository is located.
- `--repo_name`: The name of the repository from which you want to fetch artifacts.
- `--items_per_page`: (Optional) The number of items to fetch per page. Defaults to 100.
- `--output_file`: The path to the output CSV file where the results will be saved.

### Example

```bash
python fetch_all_artifacts_in_repo_using_aql_paginate.py --server_id myArtifactoryServer --repo_name my-repo-local --items_per_page 100 --output_file artifacts.csv
```

### Output

The script will save the fetched artifacts' details (name, path, actual_md5, actual_sha1) into the specified CSV file.

## Debugging

The script prints the exact JFrog CLI command being executed. If you encounter any issues, you can copy this command and run it directly in your terminal to troubleshoot.

