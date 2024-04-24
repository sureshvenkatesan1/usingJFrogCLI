#!/bin/bash
# Usage: bash Xray/Indexing/reindex_repos_enabled_for_xray_indexing.sh <YOUR_ARTIFACTORY_SERVER-ID>
# Check if the server ID argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <server-id>"
    exit 1
fi

server_id=$1

# Get the list of binMgrIds
bin_mgr_ids=$(jf xr curl "/api/v1/binMgr" --server-id "$server_id" -s | jq -r '.[].binMgrId' | sort | uniq)

# Loop through each binMgrId
for bin_mgr_id in $bin_mgr_ids; do
    echo "Fetching repositories for binMgrId: $bin_mgr_id"

    # Get the list of repositories for the current binMgrId
    repo_list=$(jf xr curl -XGET "/api/v1/binMgr/$bin_mgr_id/repos" --server-id "$server_id" -s | jq -r '
    .indexed_repos | map(.name) | .[]')

    # Loop through each repository
    for repo_name in $repo_list; do
        echo "Indexing repository: $repo_name"
        # Execute the command for each repository
        echo jf xr cl -XPOST -H \"content-type:application/json\" \"/api/v1/index/repository/$repo_name\" \
                 --server-id  "$server_id" -s
        jf xr cl -XPOST -H "content-type:application/json" "/api/v1/index/repository/$repo_name" \
                         --server-id  "$server_id" -s
    done
done
