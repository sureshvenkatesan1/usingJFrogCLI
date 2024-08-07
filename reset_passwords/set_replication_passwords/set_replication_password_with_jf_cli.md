
# Set Replication Password with JFrog CLI

This [set_replication_password_with_jf_cli.sh](set_replication_password_with_jf_cli.sh) script resets the push replication password in all local repositories that have replication configured in JFrog Artifactory. After changing the user's password in the target Artifactory server, this script should be run on the source Artifactory server to update the push replication passwords.

## Prerequisites

- JFrog CLI must be installed and configured on your system.
- `jq` must be installed for parsing JSON responses.

## Usage

```bash
./set_replication_password_with_jf_cli.sh <artifactory-server-id> <new-password>
```

### Parameters

- `<artifactory-server-id>`: The ID of the Artifactory server as configured in the JFrog CLI.
- `<new-password>`: The new password to set for the push replications.

### Example

```bash
./set_replication_password_with_jf_cli.sh my-artifactory-server newpassword123
```

## Script Details

The script performs the following steps:

1. Checks if the required parameters (server ID and new password) are provided.
2. Fetches all local repositories from the specified Artifactory server.
3. For each local repository, it checks if a push replication is defined.
4. If a push replication is defined, the script updates the password for the replication.
5. Outputs the result of the password change operation for each repository.

### Output

The script logs the output of each operation to the console and appends it to `output.txt` for later review.

## Notes

- The script uses the `--silent` and `--output /dev/null` options with `curl` to suppress the progress meter and discard the response body.
- The `--write-out %{http_code}` option is used to capture the HTTP status code of the curl requests.
- The `trap 'echo "Executing: $BASH_COMMAND"' DEBUG` line can be uncommented for debugging purposes to see each command being executed.

