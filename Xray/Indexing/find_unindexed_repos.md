# find_unindexed_repos.sh

## Overview
[find_unindexed_repos.sh](find_unindexed_repos.sh) is a script designed to identify repositories of a specified type (local, remote, or federated) that are not indexed in a given JFrog Artifactory server.

## Requirements
- JFrog CLI
- `jq` JSON processor
- 
## Usage
The script accepts two arguments: the server ID and the repository type.
```bash
bash ./find_unindexed_repos.sh <server-id> <repository-type>
```

### Parameters
- `<server-id>`: The ID of the JFrog server.
- `<repository-type>`: The type of repository to check. Possible values are `local`, `remote`, or `federated`.

### Example
```bash
bash ./find_unindexed_repos.sh psazuse local
```

## Script Details
1. The script verifies that both the server ID and repository type are provided, displaying usage information and exiting if they are not.
2. It retrieves the list of indexed repositories from the specified server.
3. It retrieves the list of repositories of the specified type (local, remote, or federated) from the server.
4. It iterates over the retrieved repositories and checks if each one is indexed, printing a message for any repository that is not indexed.

## Notes
- Ensure you have the necessary permissions and configurations set up for the JFrog CLI.
- This script relies on JFrog CLI commands and API endpoints that may vary with different versions of JFrog Artifactory.

