#!/bin/bash

# Usage: ./script_name.sh SERVERID REPO_TYPE

SERVERID="$1"
REPO_TYPE="$2"

# Check if both parameters are provided
if [[ -z "$SERVERID" || -z "$REPO_TYPE" ]]; then
  echo "Usage: $0 <SERVERID> <REPO_TYPE>"
  echo "REPO_TYPE can be LOCAL, CACHE, FEDERATED, or VIRTUAL."
  echo "Note: For REMOTE REPOS pass the <REPO_TYPE> as CACHE"
  exit 1
fi

# Fetch storage summary info using jf rt curl
JSON_OUTPUT=$(jf rt curl -s -XGET /api/storageinfo --server-id "$SERVERID")

# Check if the API call was successful
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to retrieve storage summary info."
  exit 1
fi

# Extract and sort repoKeys based on usedSpaceInBytes for the given REPO_TYPE, excluding those with usedSpaceInBytes == 0
REPO_KEYS=$(echo "$JSON_OUTPUT" | jq -r --arg REPO_TYPE "$REPO_TYPE" \
  '.repositoriesSummaryList
   | map(select(.repoType == $REPO_TYPE and .usedSpaceInBytes > 0))
   | sort_by(.usedSpaceInBytes)
   | .[].repoKey' | xargs)

# Check if any repos were found
if [[ -z "$REPO_KEYS" ]]; then
  echo "No repositories found for REPO_TYPE: $REPO_TYPE"
else
  echo "$REPO_KEYS"
fi
