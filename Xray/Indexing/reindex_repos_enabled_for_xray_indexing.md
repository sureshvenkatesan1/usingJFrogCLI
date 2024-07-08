# Reindex Repositories Enabled for Xray Indexing

The [reindex_repos_enabled_for_xray_indexing.sh](reindex_repos_enabled_for_xray_indexing.sh) script  reindexes repositories enabled for Xray indexing on a specified Artifactory server. It retrieves the list of binary manager IDs and their associated repositories, then reindexes each repository.

## Usage

To use this script, you need to have JFrog CLI installed and configured with your Artifactory server details.

### Command

```bash
bash Xray/Indexing/reindex_repos_enabled_for_xray_indexing.sh <YOUR_ARTIFACTORY_SERVER-ID>
```

### Example

```bash
bash Xray/Indexing/reindex_repos_enabled_for_xray_indexing.sh my-artifactory-server
```

## Prerequisites

- JFrog CLI installed and configured
- Access to the Artifactory server with the provided server ID
- Appropriate permissions to perform Xray indexing

## Script Details

1. **Server ID Argument Check:** The script checks if a server ID argument is provided. If not, it displays usage information and exits.

2. **Retrieve Binary Manager IDs:** The script uses the JFrog CLI to retrieve a list of binary manager IDs from the Artifactory server.

3. **Loop Through Binary Manager IDs:** For each binary manager ID, the script fetches the list of repositories enabled for Xray indexing.

4. **Reindex Repositories:** The script loops through each repository and executes a command to reindex it.

## Notes

- Ensure that the JFrog CLI is properly configured with the Artifactory server details.
- The script uses `jq` to parse JSON responses. Make sure `jq` is installed on your system.
- The script outputs the indexing command before executing it for easier debugging and verification.
