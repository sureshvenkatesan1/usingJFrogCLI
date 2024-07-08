#!/bin/bash
# Usage: bash ./find_unindexed_repos.sh psazuse <local|remote|federated>

# Define server ID and repository type
server_id="$1"
repo_type="$2"

# Check if server ID and repository type are provided
if [ -z "$server_id" ] || [ -z "$repo_type" ]; then
    echo "Usage: ./find_unindexed_repos.sh <server-id> <repository-type>"
    exit 1
fi

# Get indexed repositories
indexed_repos=$(jf xr curl -s -XGET "/api/v1/binMgr/default/repos" --server-id "$server_id" | jq -r '.indexed_repos[].name')

# Get  the local , remote or federated repositories by type
repos=$(jf rt curl -s -XGET "/api/repositories?type=$repo_type" --server-id "$server_id" | jq -r '.[] | .key')

# Iterate over local repositories and check if they are indexed
for repo in $repos; do
    if ! echo "$indexed_repos" | grep -q "$repo"; then
        echo "Repository '$repo' is not indexed."
    fi
done
