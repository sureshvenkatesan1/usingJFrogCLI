#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 ARTIFACTORY_BASE_URL MYTOKEN <repo-name1> [<repo-name2> ... <repo-nameN>]"
    exit 1
}

# Check if at least three arguments are provided (server-id, enable flag, and at least one repo name)
if [ "$#" -lt 3 ]; then
    usage
fi

# Assign the artifactory base url and access token and list of repositories (space-separated)
ARTIFACTORY_BASE_URL=$1
MYTOKEN=$2
shift 2 # Shift the positional parameters to access the repository list
REPOS=("$@")
# Assuming REPOS=("$@") is already populated with space-separated values
# Convert space-separated list to a comma-separated string with quotes
REPOS_COMMA_SEPARATED=$(printf "\"%s\"," "${REPOS[@]}")
REPOS_COMMA_SEPARATED=${REPOS_COMMA_SEPARATED%,}  # Remove the trailing comma 

# Now REPOS_COMMA_SEPARATED will be in the format: "A","B","C"

# Loop through each repository and toggle xrayIndex to true
for REPO in "${REPOS[@]}"; do
    echo ""
    echo "Processing repository: $REPO"

    # Toggle xrayIndex to true
    response=$(curl -s  -XPOST "$ARTIFACTORY_BASE_URL/artifactory/api/repositories/$REPO" \
             -H "Content-Type: application/json" \
             -H "Authorization: Bearer $MYTOKEN" \
             -d  "{\"xrayIndex\": true}")
    echo "Response: $response"
    echo ""
done

# Trigger reindexing
echo  -e  "Indexing repository: $REPOS_COMMA_SEPARATED\n\n"

# Construct the JSON payload
json_payload="{\"repos\":[$REPOS_COMMA_SEPARATED],\"filter\":{\"include_pattern\":\"**\",\"exclude_pattern\":\"\"}}"

echo  -e "json_payload to $ARTIFACTORY_BASE_URL/ui/api/v1/xray/ui/unified/indexBinMgrWithFilter: $json_payload\n\n"

# Execute the curl command with the formatted repositories
curl -s -XPOST "$ARTIFACTORY_BASE_URL/ui/api/v1/xray/ui/unified/indexBinMgrWithFilter" \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $MYTOKEN" \
    -H 'X-Requested-With: XMLHttpRequest' \
    --data-raw "$json_payload"


