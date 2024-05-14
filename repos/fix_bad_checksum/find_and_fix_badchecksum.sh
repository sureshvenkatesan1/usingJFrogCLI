#!/bin/bash
# Script used  fix the followimg error you see in the UI for an artifact:
#"Client did not publish a checksum value. If you trust the uploaded artifact you can accept the actual checksum by clicking the 'Fix Checksum' button."
# How it works:
# There is a  [Bad Checksum Search](https://www.jfrog
# .com/confluence/display/JFROG/Artifactory+REST+API#ArtifactoryRESTAPI-BadChecksumSearch) API  with which you can track down these artifacts with the missing checksum.
# It uses the Artifactory REST API and you can narrow it down to specific repositories.
#For example,
#curl -u<USER>:<PASSWORD> -XGET http://<ARTIFACTORY_SEVER>/artifactory/api/search/badChecksum?type=sha1[&repos=x[,y]]
#
# Then you can make use of the internal UI REST API ( which will be triggered on click of the ‘Fix Checksum’ button ) to apply fix checksum one file at a time.
#POST http://<ARTIFACTORY_SERVER>/artifactory/ui/checksums/fix
# The output will be displayed as:
# repo is npm-remote-cache and path is throat/-/throat-4.1.0.tgz
#{"repoKey": "npm-remote-cache", "path": "throat/-/throat-4.1.0.tgz"}
#{"info":"Successfully fixed checksum inconsistency"}
# usage:
#bash ./find_and_fix_badchecksum.sh $MY_ARTIFACTORY $MYTOKEN $REPOS_COMMA_SEPERATED
# For example:
# bash ./find_and_fix_badchecksum.sh https://abc.jfrog.io $MYTOKEN "npm-fed-local,npm-remote-cache"

MY_ARTIFACTORY=$1
MYTOKEN=$2


#comma seperated list of repos
REPOS_COMMA_SEPERATED=$3
ART_BAD_CHECKSUM_URL="$MY_ARTIFACTORY/artifactory/api/search/badChecksum?type=sha1&repos=$REPOS_COMMA_SEPERATED"

ART_FIX_CHECKSUMS_URL="$MY_ARTIFACTORY/artifactory/ui/checksums/fix"
#You can get the artifacts with the bad chacksums using jq:
#curl -s -k -H "Authorization: Bearer $MYTOKEN" -XGET $ART_BAD_CHECKSUM_URL | jq  ' .results[]' | jq -r '.uri'
#or
#just using grep
for ARTIFACT_STORAGE_URL in $(curl -k -H "Authorization: Bearer $MYTOKEN" -X GET "${ART_BAD_CHECKSUM_URL}" | grep '"uri"'  |  awk '{print $3}' | sed 's/\"//g' | sed 's/,//g')
do
    #extrcat repo and path
    #https://unix.stackexchange.com/questions/394490/how-to-cut-till-first-delimiter-and-get-remaining-part-of-strings
    repoKey=$(echo $ARTIFACT_STORAGE_URL | cut -d'/' -f7-7)
    path=$(echo $ARTIFACT_STORAGE_URL | cut -d'/' -f8-)

    printf "\n repo is ${repoKey} and path is ${path}\n"
    #fix the checksum for these documents
    doc_json="{\"repoKey\": \"$repoKey\", \"path\": \"$path\"}"
    printf "${doc_json}\n"
    curl -s -k -H "Authorization: Bearer $MYTOKEN" -X POST "${ART_FIX_CHECKSUMS_URL}" -H "Content-Type: application/json" -d "${doc_json}"

done
