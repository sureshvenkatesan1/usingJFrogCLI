# Toggle Xray Indexing for Repositories

This [toggle_enable_indexing_in_xray_for_repos.sh](toggle_enable_indexing_in_xray_for_repos.sh) script toggles Xray indexing for specified repositories in JFrog Artifactory.

## Prerequisites

- JFrog CLI must be installed and configured on your machine. You can download it from [here](https://jfrog.com/getcli/).
- Ensure you have the necessary permissions to update repository configurations in your JFrog Artifactory instance.

## Usage

You can get the list of `local` , `remote` and `federated` repos in the JPD  using the following for the `<repo-name1> [<repo-name2> ... <repo-nameN>]` :
```bash
jf rt curl -s -XGET "/api/repositories?type=local"  --server-id=psazuse | jq -r '.[] | .key' | tr '\n' ' ' > repos.txt

jf rt curl -s -XGET "/api/repositories?type=remote"  --server-id=psazuse | jq -r '.[] | .key' | tr '\n' ' ' > repos.txt

jf rt curl -s -XGET "/api/repositories?type=federated"  --server-id=psazuse | jq -r '.[] | .key' | tr '\n' ' ' > repos.txt
```
The toggle the Xray indexing for only specific repos from  the above `repos.txt` output file  using :
```
./toggle_enable_indexing_in_xray_for_repos.sh <server-id> <enable> <repo-name1> [<repo-name2> ... <repo-nameN>]
```
or 

toggle for all repos in `repos.txt` you can use:
```
./toggle_enable_indexing_in_xray_for_repos.sh <server-id> <enable> $(cat repos.txt)
```

- `<server-id>`: The server ID of your JFrog Artifactory instance.
- `<enable>`: Set to `true` to enable Xray indexing or `false` to disable Xray indexing.
- `<repo-name1> [<repo-name2> ... <repo-nameN>]`: A list of one or more repository names for which you want to toggle the Xray indexing.


### Example

Enable Xray indexing:
```bash
./toggle_enable_indexing_in_xray_for_repos.sh myServerID true myRepo1 myRepo2 myRepo3
```

Disable Xray indexing:
```bash
./toggle_enable_indexing_in_xray_for_repos.sh myServerID false myRepo1 myRepo2 myRepo3
```

## How It Works

1. **Argument Validation**: The script checks if the required arguments (server ID, enable flag, and at least one repository name) are provided.
2. **Enable Flag Validation**: The script ensures the enable flag is either `true` or `false`.
3. **Create Configuration File**: A temporary JSON file is created with the `xrayIndex` property set to `true` or `false` based on the enable flag.
4. **Update Repositories**: The script iterates through each repository name and uses the JFrog CLI to send a POST request to update the repository configuration, enabling or disabling Xray indexing.
5. **Clean Up**: The temporary JSON file is removed.

## Notes

- Regularly clean up the `jfrog-cli*.log` files under your `~/.jfrog/logs` folder as this script runs multiple JFrog CLI commands, generating a new `jfrog-cli*.log` file for each command.