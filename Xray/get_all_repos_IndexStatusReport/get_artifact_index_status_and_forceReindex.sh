#!/bin/bash

jfrogURL=$1
username=$2
password=$3
repoKey=$4
tempFilesListOutput=filesList.txt
######### Example command: ./xrayIndexingReport.sh localhost:8082 admin password nuget-local
curl -u "$username":"$password" -L -s "$jfrogURL/artifactory/api/storage/$repoKey?list&deep=1" | jq -r '.files[].uri'  >> $tempFilesListOutput
while IFS= read -r line
do
printf "%s" $line >> indexingStatusReport.txt
printf '\t' >> indexingStatusReport.txt
echo $line | xargs -I % curl -u "$username":"$password" -L -s "$jfrogURL/artifactory/ui/artifactxray?path=%&repoKey=$repoKey" | jq -r '.xrayIndexStatus' >> indexingStatusReport.txt
curl -u "$username":"$password" -X POST "$jfrogURL/xray/api/v1/forceReindex" -H 'Content-Type: application/json' -d '{
"artifacts": [
{
"repository": "'"$repoKey"'",
"path": "'"$line"'"

        }
    ]
}'
#  echo >> indexingStatusReport.txt
done < filesList.txt
rm $tempFilesListOutput