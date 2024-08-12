
# sort_repos_by_type_in_ascending_usedSpaceInBytes.sh

## Overview

The [sort_repos_by_type_in_ascending_usedSpaceInBytes.sh](sort_repos_by_type_in_ascending_usedSpaceInBytes.sh) script is a shell script designed to fetch and sort JFrog Artifactory repository information based on the storage space used. The script retrieves the storage summary information from the Artifactory instance, filters the repositories by type, and sorts them in ascending order based on the used space in bytes. Repositories with `usedSpaceInBytes` equal to 0 are excluded from the results.

## Prerequisites

- [JFrog CLI](https://jfrog.com/getcli/) must be installed and configured with your Artifactory server.
- The `jq` command-line JSON processor must be installed.

## Usage

```bash
./sort_repos_by_type_in_ascending_usedSpaceInBytes.sh <SERVERID> <REPO_TYPE>
```

### Parameters

- `SERVERID`: The server ID configured in your JFrog CLI configuration. This identifies which Artifactory instance to query.
- `REPO_TYPE`: The type of repository to filter and sort. Accepted values are:
    - `LOCAL`: Local repositories.
    - `CACHE`: Remote cache repositories.
    - `FEDERATED`: Federated repositories.
    - `VIRTUAL`: Virtual repositories.

  **Note:** For remote repositories, pass the `<REPO_TYPE>` as `CACHE`.

## Example

To sort local repositories on the server `my-artifactory` by the used space in ascending order:

```bash
./sort_repos_by_type_in_ascending_usedSpaceInBytes.sh my-artifactory-serverid LOCAL
```

This will output the repository keys of all local repositories sorted by the space they are using, excluding those that have `usedSpaceInBytes` equal to 0.

## Error Handling

- If the script fails to retrieve storage summary information, it will print an error message and exit.
- If no repositories of the specified type are found, or if all found repositories have `usedSpaceInBytes` equal to 0, a message will be printed indicating that no repositories were found for the specified type.

## Dependencies

- **JFrog CLI**: Used to interact with the JFrog Artifactory API.
- **jq**: Used to parse and filter JSON data from the API response.

