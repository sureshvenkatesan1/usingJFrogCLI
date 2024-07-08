#!/bin/bash 

artifactoryURL=$1
MYTOKEN=$2
repoKey=$3
tempFilesListOutput=filesList.txt

######### Example command: ./getIndexStatus.sh localhost:8082/artifactory $MYTOKEN nuget-local

#curl -u "$username":"$password" -L -s "$artifactoryURL/api/storage/$repoKey?list&deep=1" -vvv | jq -r '.files[].uri' >> $tempFilesListOutput
curl -s -X GET -H "Authorization: Bearer $MYTOKEN" -L  "$artifactoryURL/api/storage/$repoKey?list&deep=1" -vvv | jq -r '.files[].uri' >> $tempFilesListOutput

while IFS= read -r line
do
  printf "%s" $line >> indexingStatusReport.txt
  printf '\t' >> indexingStatusReport.txt
  echo $line | xargs -I % curl -s -X GET -H "Authorization: Bearer $MYTOKEN" -L  "$artifactoryURL/ui/artifactxray?path=%&repoKey=$repoKey" | jq -r '.xrayIndexStatus' >> indexingStatusReport.txt
#  echo >> indexingStatusReport.txt
done < filesList.txt

rm $tempFilesListOutput
