
# Set Remote Repository Password Script

This [set_remote_repo_password_with_jf_cli.sh](set_remote_repo_password_with_jf_cli.sh) script is designed to update 
the password for remote repositories in JFrog Artifactory using the JFrog CLI. It 
constructs a JSON payload for the new password and applies it to each specified repository.

## Usage

You can get the list of   `remote`   repos in the JPD  using the following for the `<repo-name1> 
[<repo-name2> ... <repo-nameN>]` :
```bash

jf rt curl -s -XGET "/api/repositories?type=remote"  --server-id=yourserverid | jq -r '.[] | .key' | tr '\n' ' ' > 
repos.txt
```
Then use the set_remote_repo_password_with_jf_cli.sh to update the username and password one or more remote repos:
```sh
./set_remote_repo_password_with_jf_cli.sh <server-id> <new-user> <new-password> <repo-name1> [<repo-name2> ... <repo-nameN>]
```

Or to use a list of repository names from a file:

```sh
./set_remote_repo_password_with_jf_cli.sh <server-id> <new-user> <new-password> $(cat repos.txt)
```

### Parameters

- `<server-id>`: The ID of the JFrog server configured in your JFrog CLI.
- `<new-user>`: The new username to set for the repositories (optional if you only need to change the password).
- `<new-password>`: The new password to set for the repositories.
- `<repo-name1> [<repo-name2> ... <repo-nameN>]`: One or more repository names to update. You can also pass the repository names from a file using `$(cat repos.txt)`.

### Examples

1. Update a single repository:

   ```sh
   ./set_remote_repo_password_with_jf_cli.sh my-server-id my-username my-new-password my-repo-name
   ```

2. Update multiple repositories:

   ```sh
   ./set_remote_repo_password_with_jf_cli.sh my-server-id my-username my-new-password repo1 repo2 repo3
   ```

3. Update repositories listed in a file:

   ```sh
   ./set_remote_repo_password_with_jf_cli.sh my-server-id my-username my-new-password $(cat repos.txt)
   ```

### Script Details

The script performs the following steps:

1. **Usage Check**: Ensures the correct number of arguments are provided.
2. **Temporary File Creation**: Creates a temporary file to hold the JSON payload for the password update.
3. **Password Update Function**:
    - Constructs the JSON payload with the new username and password.
    - Sends a POST request to update the repository configuration with the new password.
    - Checks the HTTP status code to determine if the update was successful.
4. **Loop Through Repositories**: Iterates through each specified repository and calls the password update function.
5. **Clean Up**: Removes the temporary file used for the JSON payload.



### Notes

- Ensure you have the JFrog CLI installed and configured with the appropriate server ID.
- The script logs the status of each password update operation to `output.txt`.
- If the update fails, the script will output an error message indicating the failure.
