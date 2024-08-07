#!/bin/bash
# Script used  to reset the push replication password in all local repos which had replication configured. All these
# push replications used the same  user  credentials so  after changing the user's password in the
# target Artifactory server we ran this script  on  the source Artifactory.

# Enable exit on error and set debug trap
#set -e
#trap 'echo "Executing: $BASH_COMMAND"' DEBUG

# Check if the server ID and password are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <artifactory-server-id> <new-password>"
  exit 1
fi

SERVER_ID=$1
NEW_PASSWORD=$2

#Point the JFrog CLI to the correct Artifactory server
#jf config use sureshv-artifactory-ha1
#turn off output - needed for curl to run in --silent  mode
#export CI=true
#export JFROG_CLI_LEVEL=ERROR
#Fetch all local repositories
for repo in $(jf rt curl -s -XGET "/api/repositories?type=local" --server-id="${SERVER_ID}" |   jq -r '.[].key'); do
  printf "\n${repo}\n"
  #check if the repo  has a PUSH replication defined
  status_code=$(jf rt  curl  --write-out %{http_code} --output /dev/null  -XGET "/api/replications/${repo}"  --server-id="${SERVER_ID}")
  echo "$status_code"
  if [[ "$status_code" -ne 404 ]] ; then
    #repo  has a PUSH replication defined. So change the password
    printf "changing replication password for ${repo}\n" | tee -a output.txt
    change_status=$(jf rt curl --write-out %{http_code} -s -XPOST "/api/replications/${repo}" --header 'Content-Type: application/json' \
    --data-raw "{
      \"password\" : \"${NEW_PASSWORD}\"
    }" --server-id="${SERVER_ID}")

    if [[ "$change_status" -eq 200 ]] || [[ "$change_status" -eq 201 ]]; then
      printf "Replication password for ${repo} changed successfully\n" | tee -a output.txt
    else
      printf "Failed to change replication password for ${repo}\n" | tee -a output.txt
    fi
  else
    printf "no push replication defined for  local repo ${repo}\n" | tee -a output.txt
  fi
done