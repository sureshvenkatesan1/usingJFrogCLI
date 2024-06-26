#!/bin/bash
# bash get_artifact_index_status_and_forceReindex_with_jf.sh soleng ad-npm-local-temp
if [ $# -ne 2 ]; then
    echo "Usage: $0 <server-id> <reponame>"
    exit 1
fi

server_id=$1

repoKey=$2
tempFilesListOutput=filesList.txt
indexingStatusReport=indexingStatusReport.txt


# Get list of files from Artifactory
jf rt curl  -L -s -XGET "/api/storage/$repoKey?list&deep=1" --server-id "$server_id" | jq -r '.files[].uri' >> "$tempFilesListOutput"


while IFS= read -r line; do
    printf "%s" "$line" >> "$indexingStatusReport"
    printf '\t' >> "$indexingStatusReport"
    # Get Xray indexing status
    xrayIndexStatus=$(echo "$line" | xargs -I % jf rt curl -L -s "/ui/artifactxray?path=%&repoKey=$repoKey" --server-id "$server_id" | jq -r '.xrayIndexStatus')
    echo "$xrayIndexStatus" >> indexingStatusReport.txt

    # If Xray indexing status is "Not indexed", trigger indexing
    if [[ "$xrayIndexStatus" == *"Not indexed" ]]; then
      jf xr curl  -X POST "/api/v1/forceReindex" \
            -H "Content-Type: application/json" --server-id "$server_id" -d '{
        "artifacts": [
        {
        "repository": "'"$repoKey"'",
        "path": "'"$line"'"

                }
            ]
        }'
      echo ""
      echo "indexed $repoKey$line"
    fi

#  echo >> indexingStatusReport.txt
done < "$tempFilesListOutput"
# Clean up
rm "$tempFilesListOutput"