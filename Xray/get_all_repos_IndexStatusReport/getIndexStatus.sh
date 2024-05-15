#!/bin/bash 

artifactoryURL=$1
username=$2
password=$3
repoKey=$4
tempFilesListOutput=filesList.txt

######### Example command: ./xrayIndexingReport.sh localhost:8082/artifactory admin password nuget-local

curl -u "$username":"$password" -L -s "$artifactoryURL/api/storage/$repoKey?list&deep=1" -vvv | jq -r '.files[].uri' >> $tempFilesListOutput

while IFS= read -r line
do
  printf "%s" $line >> indexingStatusReport.txt
  printf '\t' >> indexingStatusReport.txt
  echo $line | xargs -I % curl -u "$username":"$password" -L -s "$artifactoryURL/ui/artifactxray?path=%&repoKey=$repoKey" | jq -r '.xrayIndexStatus' >> indexingStatusReport.txt
#  echo >> indexingStatusReport.txt
done < filesList.txt

rm $tempFilesListOutput
