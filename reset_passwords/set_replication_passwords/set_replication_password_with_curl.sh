#!/bin/bash
# Script used  to reset the push replication password in 50+ local repos . All these push replications used the same
# user  credentials so  after changing the user's password in the target Artifactory server we ran this script  on
# the source Artifactory. After it sets the replication password for each repo it outputs the modified replication
# configuration.

NEW_REPLICATION_PASSWORD=$1

ART_ROOT="$PROTOCOL://$MYSERVERHOST_IP/artifactory/api"
for REPO in $(curl -s -S -X GET "${ART_ROOT}/repositories?type=local" | grep "key" | awk '{print $3}' | sed 's/\"//g' | sed 's/,//g')
do
    #check if the repo  has a PUSH replication defined
    status_code=$(curl -u "${MYUSER}:${MYPASSWORD}" -s -S --write-out %{http_code} --output /dev/null -X GET
    "${ART_ROOT}/replications/${REPO}")
  if [[ "$status_code" -ne 404 ]] ; then
    printf "Return is ${status_code} changing replication password for ${REPO}\n"
    ret=$(curl -u "${MYUSER}:${MYPASSWORD}" -s -S -X POST "${ART_ROOT}/replications/${REPO}" --header 'Content-Type:
    application/json' --data '{ "password" : "${NEW_REPLICATION_PASSWORD}", "enableEventReplication": true }')
    if [[ $? != 0 ]]
     then
        printf "ERR: $ret, please update manually for ${REPO}"
    else
        curl -u "${MYUSER}:${MYPASSWORD}" -s -S -X GET "${ART_ROOT}/replications/${REPO}"
    fi
  else
    printf "Return is ${status_code} no push replication defined for local repo ${REPO}\n"
  fi
done

