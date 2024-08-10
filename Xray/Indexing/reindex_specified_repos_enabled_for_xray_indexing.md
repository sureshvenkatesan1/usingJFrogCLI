
# Reindex Specified Repositories Enabled for Xray Indexing

[reindex_specified_repos_enabled_for_xray_indexing.sh](reindex_specified_repos_enabled_for_xray_indexing.sh) enables Xray indexing for specified repositories in JFrog Artifactory and then triggers reindexing for those repositories. The script requires JFrog CLI to interact with the JFrog platform.

## Prerequisites

- **JFrog CLI**: Ensure that JFrog CLI is installed and configured with the appropriate server ID.

## Usage

You can get the list of `local` , `remote` and `federated` repos in the JPD  using the following for the `<repo-name1> [<repo-name2> ... <repo-nameN>]` :
```bash
jf rt curl -s -XGET "/api/repositories?type=local"  --server-id=psazuse | jq -r '.[] | .key' | tr '\n' ' ' > repos.txt

jf rt curl -s -XGET "/api/repositories?type=remote"  --server-id=psazuse | jq -r '.[] | .key' | tr '\n' ' ' > repos.txt

jf rt curl -s -XGET "/api/repositories?type=federated"  --server-id=psazuse | jq -r '.[] | .key' | tr '\n' ' ' > repos.txt
```
Then index only specific repos from  the above `repos.txt` output file (like 1 repo is it is 
huge  or 1-5 repos for smaller repos )  at a time using :

Note: As mentioned in ["Onboarding Best Practices: JFrog Xray"](https://jfrog.com/help/r/get-started-with-the-jfrog-platform/onboarding-best-practices-jfrog-xray) it is not recommended to index
all  repos in artifactory at the same time.

It is recommended to index a small group of repos  at a time and wait for them to get indexed before moving to the next
group


```
./reindex_specified_repos_enabled_for_xray_indexing.sh <server-id> <repo-name1> [<repo-name2> ... <repo-nameN>]
```

### Parameters

- `<server-id>`: The ID of the JFrog server where the repositories are hosted.
- `<repo-name1> [<repo-name2> ... <repo-nameN>]`: A space-separated list of repository names for which Xray indexing should be enabled and reindexed.

### Example

```bash
./reindex_specified_repos_enabled_for_xray_indexing.sh myServerID green-npm-dev-local krishnam-docker-dev-local sunil-npm-local
```

This command will:
1. Enable Xray indexing for the repositories `green-npm-dev-local`, `krishnam-docker-dev-local`, and `sunil-npm-local` on the server `myServerID`.
2. Trigger reindexing for the specified repositories.

## Script Details

The script performs the following steps for each repository:

1. **Enable Xray Indexing**:
    - Sends a `POST` request to the Artifactory API to enable Xray indexing by setting `"xrayIndex": true` for the 
      specified repository.
2. **Trigger Reindexing**:
    - Sends a `POST` request to the Xray API to trigger reindexing for the specified repository.

## Error Handling

- If the script is not provided with the required arguments, it will display a usage message and exit.
- The response from the Artifactory API after attempting to enable Xray indexing is printed for each repository.

## Notes

- Ensure that you have the necessary permissions to perform the operations on the specified repositories.
- The script assumes that the server ID and repositories are valid and correctly configured in JFrog Artifactory.
