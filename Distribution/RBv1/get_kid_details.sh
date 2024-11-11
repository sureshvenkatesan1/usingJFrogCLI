#!/bin/bash

# Check if all required parameters are provided
if [ $# -ne 4 ]; then
  echo "Usage: ./get_kid_details.sh <MYTOKEN> <ARTIFACTORY_BASE_URL> <RELEASE_BUNDLE_NAME> <RELEASE_BUNDLE_VERSION>"
  exit 1
fi

# Assign parameters to variables
MYTOKEN=$1
ARTIFACTORY_BASE_URL=$2
RELEASE_BUNDLE_NAME=$3
RELEASE_BUNDLE_VERSION=$4

# Get the release bundle details in JWS format
response=$(curl -s -X GET -H "Authorization: Bearer $MYTOKEN" "https://$ARTIFACTORY_BASE_URL/distribution/api/v1/release_bundle/$RELEASE_BUNDLE_NAME/$RELEASE_BUNDLE_VERSION?format=jws")

# Extract the header value
header=$(echo "$response" | jq -r '.header')

# Decode the Base64 encoded header to get the JSON object
decoded_header=$(echo "$header" | base64 --decode)

# Extract the value of "kid" from the decoded header
kid=$(echo "$decoded_header" | jq -r '.kid')

# Debugging: print the extracted kid value
echo "Extracted kid: $kid"

# Get the key details from the keys management API
key_details=$(curl -s -X GET -H "Authorization: Bearer $MYTOKEN" "https://$ARTIFACTORY_BASE_URL/ui/api/v1/ui/security/trustedKeys")

# Debugging: print the key details
echo "Key details: $key_details"

# Extract the details for the specific "kid"
kid_details=$(echo "$key_details" | jq -r --arg kid "$kid" '.[] | select(.kid == $kid)')

# Debugging: print the matched kid details
#echo "Matched kid details: $kid_details"

# Print the "kid" details
echo "The details for kid '$kid' are:"
echo "$kid_details"
