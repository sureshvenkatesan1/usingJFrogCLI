#!/bin/bash

# Usage function to display help for the script
usage() {
  echo "Usage: $0 <server-id> <new-user> <new-password> <repo-name1> [<repo-name2> ... <repo-nameN>]"
  echo "or"
  echo "$0 <server-id>  <new-user> <new-password> \$(cat repos.txt)"
  exit 1
}

# Check if at least three arguments are provided
if [ "$#" -lt 4 ]; then
  usage
fi

# JFrog CLI server ID and new password
SERVER_ID="$1"
NEW_USER="$2"
NEW_PASSWORD="$3"
shift 3

# List of repositories
REPO_NAMES="$@"

# Temporary file for JSON payload
password_json=$(mktemp)

# Function to update the password of a remote repository
update_repo_password() {
  local repo_key=$1
  echo "Updating password for remote repository: $repo_key"

  # Construct JSON payload for the password . Note : just  password is sufficient if you are using the same username.
  # I am specifying  username, password only for clarity and example from  273872
  echo "{ \"username\": \"${NEW_USER}\", \"password\": \"${NEW_PASSWORD}\"}" >   "$password_json"


  # Apply the updated password using a POST request
  http_code=$(jf rt  curl   --write-out %{http_code} --output /dev/null  -XPOST "/api/repositories/$repo_key" -H   "Content-Type: application/json" -T "$password_json" --server-id "$SERVER_ID")

  if [[ "$http_code" -eq 200 ]] || [[ "$http_code" -eq 201 ]]; then
    printf "Remote password for ${repo_key} changed successfully\n" | tee -a output.txt
  else
    printf "Failed to change remote password for ${repo_key}\n" | tee -a output.txt
    cat response.txt
  fi

}

# Loop through each repository name and update its password
for repo in $REPO_NAMES; do
  update_repo_password $repo
done

# Clean up temporary file
 rm -f "$password_json"

echo "Password reset completed for specified remote repositories.\n" | tee -a output.txt
