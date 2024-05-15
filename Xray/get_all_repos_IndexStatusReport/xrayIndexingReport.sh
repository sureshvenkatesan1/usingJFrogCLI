#!/bin/bash

# This script script automates the process of searching for files in an Artifactory repository, filtering based on
# the specified repository name and type , Xray indexing retention period for the repo  , and generates a
# report on  the indexing  status of each of those files in Xray.

# Here's what the script does in more detail:

# 1. The script takes three arguments: `repoKey`, `repoType`, and `repoRetention`. These are used to define the repository to search in, the type of package to search for, and the retention period for the files respectively.

# 2. The script sends a GET request to the Artifactory Xray API to retrieve a list of supported package types. It then uses `jq` to filter the list to only include package types that match the specified `repoType` and have a file extension. The resulting list of extensions is then used to create an AQL filter to match files in the repository.

# 3. The script constructs an AQL query using the `repoKey`, `aqlFilter`, and `timeFilter` variables. The `aqlFilter` variable contains the filter generated in step 2, and the `timeFilter` variable specifies a date range based on the `repoRetention` argument. The resulting AQL query searches for files in the specified repository that were created or modified within the specified retention period and match the file extension filter.

# 4. The script sends a POST request to the Artifactory AQL search API with the constructed AQL query to retrieve a list of matching files. The results are then parsed using `jq` to extract the file paths and names.

# 5. The script writes the list of file paths and names to a temporary file called `filesList.txt`, removing the leading "./" from the paths.

# 6. The script loops through each file in `filesList.txt` and sends a GET request to the Artifactory Xray UI API to retrieve the indexing status of the file. The indexing status is then appended to a report file called `indexingStatusReport.txt`.

# 7. The temporary file `filesList.txt` is deleted.



artifactoryURL="$ARTIFACTORY_URL"
username="$ARTIFACTORY_USERNAME"
password="$ARTIFACTORY_PASSWORD"
repoKey=$1
repoType=$2
repoRetention=$3
tempFilesListOutput=filesList.txt

aqlFilter=$(curl -s -u "$username":"$password" $artifactoryURL/xray/api/v1/supportedTechnologies | jq --arg repoType "$repoType" '.supported_package_types | map(select(.type == $repoType).extensions[]) | map(if .is_file != true then {"name" : {"$match":("*"+.extension)}} else {"name" : {"$eq":.extension}} end)')
read -r -d '' timeFilter <<- EOM
  "\$or":[
    {"created" : {"\$last" : "${repoRetention}d"}},
    {"modified" : {"\$last" : "${repoRetention}d"}}
  ]
EOM
aqlQuery="items.find({\"repo\":\"$repoKey\",\"\$or\":$aqlFilter,$timeFilter}).include(\"path\",\"name\",\"created\",\"modified\")"

curl -s -u "$username":"$password" -XPOST -H "Content-Type: text/plain" "$artifactoryURL/artifactory/api/search/aql" -d "$aqlQuery" | jq -r '.results[] | .path + "/" + .name' >> $tempFilesListOutput
sed -i 's/^.\//\//g' $tempFilesListOutput
while IFS= read -r line
do
 printf "%s" $line >> indexingStatusReport.txt
 printf '\t' >> indexingStatusReport.txt
 echo $line | xargs -I % curl -u "$username":"$password" -L -s "$artifactoryURL/artifactory/ui/artifactxray?path=%&repoKey=$repoKey" | jq -r '.xrayIndexStatus' >> indexingStatusReport.txt
  echo >> indexingStatusReport.txt
done < filesList.txt
rm $tempFilesListOutput