#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 <server-id> <enable> <repo-name1> [<repo-name2> ... <repo-nameN>]"
    echo "<enable> should be 'true' to enable Xray indexing or 'false' to disable Xray indexing."
    exit 1
}

# Check if at least three arguments are provided (server-id, enable flag, and at least one repo name)
if [ "$#" -lt 3 ]; then
    usage
fi

# Assign the server-id and the enable flag
server_id="$1"
enable_flag="$2"
shift 2
repo_names=("$@")

# Validate enable flag
if [ "$enable_flag" != "true" ] && [ "$enable_flag" != "false" ]; then
    usage
fi

# Create a temporary JSON file for the Xray indexing configuration
xray_json=$(mktemp)
if [ "$enable_flag" == "true" ]; then
    echo '{"xrayIndex" : true}' > "$xray_json"
else
    echo '{"xrayIndex" : false}' > "$xray_json"
fi

# Loop through each repository name and set Xray indexing
for repo_name in "${repo_names[@]}"; do
    if [ "$enable_flag" == "true" ]; then
        echo "Enabling Xray indexing for repository: $repo_name"
    else
        echo "Disabling Xray indexing for repository: $repo_name"
    fi
    response=$(jf rt curl -s  -XPOST "/api/repositories/$repo_name" -H "Content-Type: application/json" -T "$xray_json"  --server-id "$server_id")
    echo "Response: $response"
done

# Clean up the temporary JSON file
rm -f "$xray_json"

if [ "$enable_flag" == "true" ]; then
    echo "Xray indexing enabled for all specified repositories."
else
    echo "Xray indexing disabled for all specified repositories."
fi
