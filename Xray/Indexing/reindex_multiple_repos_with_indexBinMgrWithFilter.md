
# Reindex Multiple Repositories with Xray's `indexBinMgrWithFilter` API

This script automates the process of reindexing multiple repositories in JFrog Xray using the internal 
`indexBinMgrWithFilter` API  similar to the one  triggered when indexing from the   
Jfrog UI .
Note: These are internal APIs and may be subject to change.

It fetches the list of repositories for each `binMgrId` and constructs a JSON 
payload to reindex these repositories.

## Prerequisites

- JFrog Xray installed and running.
- A valid API token with appropriate permissions to access the Xray API.

## Usage

### Script Parameters

The script requires two parameters:
1. `ARTIFACTORY_BASE_URL`: The base URL of your JFrog Artifactory instance.
2. `MYTOKEN`: Your JFrog API token.

### Running the Script

To execute the script, use the following command:

```sh
./reindex_multiple_repos_with_indexBinMgrWithFilter.sh <ARTIFACTORY_BASE_URL> <MYTOKEN>
```

### Example

```sh
./reindex_multiple_repos_with_indexBinMgrWithFilter.sh "https://myartifactory.jfrog.io" "mytoken123"
```

## Notes

- Uncomment `set -x` at the beginning of the script to enable debugging.
- The script fetches all `binMgrId`s and processes each one in turn.
- The script constructs a JSON payload for each `binMgrId` and sends it to the `indexBinMgrWithFilter` API to reindex the repositories.

