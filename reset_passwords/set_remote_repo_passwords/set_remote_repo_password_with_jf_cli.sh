#!/bin/bash

# JFrog CLI server ID
SERVER_ID="your-server-id"
NEW_PASSWORD="your-new-password"

# Function to update the password of a remote repository
update_repo_password() {
  local repo_key=$1
  echo "Updating password for remote repository: $repo_key"

  # Fetch the current repository configuration
  repo_config=$(jf rt curl -X GET /api/repositories/$repo_key --server-id=$SERVER_ID)

  # Check if the repository configuration was fetched successfully
  if [ $? -ne 0 ]; then
    echo "Failed to fetch configuration for $repo_key"
    return 1
  fi

  # Update the password in the configuration
  updated_config=$(echo $repo_config | jq --arg new_password "$NEW_PASSWORD" '.rclass = "remote" | .url |= . + " " | .password = $new_password')

  # Apply the updated configuration
  jf rt curl -X PUT /api/repositories/$repo_key -H "Content-Type: application/json" -d "$updated_config" --server-id=$SERVER_ID

  if [ $? -ne 0 ]; then
    echo "Failed to update password for $repo_key"
  else
    echo "Password updated for $repo_key"
  fi
}

# Fetch the list of remote repositories
remote_repos=$(jf rt curl -X GET /api/repositories --server-id=$SERVER_ID | jq -r '.[] | select(.rclass == "remote") | .key')

if [ -z "$remote_repos" ]; then
  echo "No remote repositories found."
  exit 1
fi

# Loop through each remote repository and update its password
for repo in $remote_repos; do
  update_repo_password $repo
done

echo "Password reset completed for all remote repositories."
