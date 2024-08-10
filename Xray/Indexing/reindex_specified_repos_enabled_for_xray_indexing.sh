#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 <server-id>  <repo-name1> [<repo-name2> ... <repo-nameN>]"
    exit 1
}

# Check if at least three arguments are provided (server-id, enable flag, and at least one repo name)
if [ "$#" -lt 2 ]; then
    usage
fi

# Assign the server-id
# Input: Server ID and list of repositories (space-separated)
SERVER_ID=$1
shift 1 # Shift the positional parameters to access the repository list
REPOS=("$@")

# Loop through each repository and toggle xrayIndex to true
for REPO in "${REPOS[@]}"; do
    echo ""
    echo "Processing repository: $REPO"

    # Toggle xrayIndex to true
    response=$(jf rt curl -s  -XPOST "/api/repositories/$REPO" \
             -H "Content-Type: application/json" \
             -d  "{\"xrayIndex\": true}" --server-id "$SERVER_ID")
    echo "Response: $response"

    # Trigger reindexing
    echo "Indexing repository: $REPO"
    # Execute the command for each repository
    echo jf xr cl -XPOST -H \"content-type:application/json\" \"/api/v1/index/repository/$REPO\" \
             --server-id  "$SERVER_ID" -s
    jf xr cl -XPOST -H "content-type:application/json" "/api/v1/index/repository/$REPO" \
                     --server-id  "$SERVER_ID" -s
    echo ""
done
