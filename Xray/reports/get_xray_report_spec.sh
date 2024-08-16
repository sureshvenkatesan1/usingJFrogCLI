#!/bin/bash

# Input parameters
ARTIFACTORY_BASE_URL=$1
MYTOKEN=$2
REPORT_NAME=$3
NUM_OF_ROWS=${4:-1000}  # Default value is 1000 if not provided

# Validate inputs
if [[ -z "$ARTIFACTORY_BASE_URL" || -z "$MYTOKEN" || -z "$REPORT_NAME" ]]; then
  echo "Usage: $0 <ARTIFACTORY_BASE_URL> <MYTOKEN> <REPORT_NAME> [NUM_OF_ROWS]"
  exit 1
fi

# Fetch reports list using Xray API
echo "Fetching report ID for report name: $REPORT_NAME..."
REPORTS_LIST=$(curl -s -XPOST -H "Authorization: Bearer $MYTOKEN" "${ARTIFACTORY_BASE_URL}/xray/api/v1/reports?direction=asc&page_num=1&num_of_rows=${NUM_OF_ROWS}")
#echo "$REPORTS_LIST"

# Extract report ID using jq
REPORT_ID=$(echo "$REPORTS_LIST" | jq -r --arg REPORT_NAME "$REPORT_NAME" '.reports[] | select(.name == $REPORT_NAME) | .id')

if [[ -z "$REPORT_ID" ]]; then
  echo "Error: Report with name '$REPORT_NAME' not found in the first ${NUM_OF_ROWS} reports."
  exit 1
fi

echo "Report ID for '$REPORT_NAME': $REPORT_ID"

# Use the report ID in the internal API to fetch vulnerabilities spec
echo "Fetching vulnerabilities spec for report ID: $REPORT_ID..."
VULNERABILITIES_SPEC=$(curl -s -XGET -H "Authorization: Bearer $MYTOKEN" "${ARTIFACTORY_BASE_URL}/ui/api/v1/xray/ui/reports/vulnerabilities/spec/${REPORT_ID}")

# Display the fetched spec
echo "Vulnerabilities Spec for report ID ${REPORT_ID}:"
echo "$VULNERABILITIES_SPEC"
