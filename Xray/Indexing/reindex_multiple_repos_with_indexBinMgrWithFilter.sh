#!/bin/bash

# Enable debugging to show the actual commands being executed
#set -x
# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 ARTIFACTORY_BASE_URL MYTOKEN"
    exit 1
fi

# Assign the parameters to variables
ARTIFACTORY_BASE_URL=$1
MYTOKEN=$2


# Fetch repositories and format the output
#REPOS=$(curl -s -XGET "$ARTIFACTORY_BASE_URL/artifactory/api/repositories?type=$REPOTYPE" -H "Authorization: Bearer $MYTOKEN" | jq -r '.[] | "\"\(.key)\""' | tr '\n' ',' | sed 's/,$//')

# Get the list of binMgrIds
bin_mgr_ids=$(curl -s -XGET "$ARTIFACTORY_BASE_URL/xray/api/v1/binMgr" -H "Authorization: Bearer $MYTOKEN" | jq -r '.[].binMgrId' | sort | uniq)

# Loop through each binMgrId
for bin_mgr_id in $bin_mgr_ids; do
    echo "Fetching repositories for binMgrId: $bin_mgr_id"

    # Get the list of repositories for the current binMgrId
    repo_list=$(curl -s -XGET "$ARTIFACTORY_BASE_URL/xray/api/v1/binMgr/$bin_mgr_id/repos"  -H "Authorization: Bearer $MYTOKEN"  |jq -r '.indexed_repos | map("\"" + .name + "\"") | join(",")')

    # Print the formatted REPOS variable to check the output
    echo -e "$repo_list\n\n"

    # Construct the JSON payload
    json_payload="{\"repos\":[$repo_list],\"filter\":{\"include_pattern\":\"**\",\"exclude_pattern\":\"\"}}"

    echo  -e "$json_payload"

    # Execute the curl command with the formatted repositories
    curl -s -XPOST "$ARTIFACTORY_BASE_URL/ui/api/v1/xray/ui/unified/indexBinMgrWithFilter" \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer $MYTOKEN" \
      -H 'X-Requested-With: XMLHttpRequest' \
      --data-raw "$json_payload"
done

# Disable debugging after script execution
#set +x