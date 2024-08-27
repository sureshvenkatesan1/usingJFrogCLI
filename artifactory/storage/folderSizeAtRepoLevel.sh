#!/bin/bash

# find the size of all folders in a specific Artifactory repository and save the results to a file.
# Usage:
#$ ./folderSizeAtRepoLevel.sh
# Sample Output:
#Folder size for --> marvel
#{
#  "artifactsCount" : 13,
#  "artifactSize" : "53.02 MB"
#}
#Folder size for --> openjdk
#{
#  "artifactsCount" : 9,
#  "artifactSize" : "318.58 MB"
#}
#Folder size for --> test
#{
#  "artifactsCount" : 15,
#  "artifactSize" : "295.14 MB"
#}


curl -s -k -H 'Content-Type:text/plain' -udeepti:Password@123 -XPOST "https://customer.jfrog.io/artifactory/api/search/aql" -d 'items.find({"type":"folder","repo":{"$match":"test-repo-local"},"depth":1})' | grep "name" | awk '{print $3}' | sed 's/"//g'  | sed 's/,//g' | awk 'length > 1' > folders.txt

for folder in $(cat folders.txt);
do
echo "Folder size for -->"  $folder
curl -X POST -H "Content-Type:application/json" -udeepti:Password@123 "https://customer.jfrog.io/artifactory/ui/artifactgeneral/artifactsCount?$no_spinner=true" -d '{"name":"'"$folder"'","repositoryPath":"test-repo-local/'"$folder"'/"}'
printf "\n"
done