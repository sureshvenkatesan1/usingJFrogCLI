
# Get Xray Report Spec Script

This [get_xray_report_spec.sh](get_xray_report_spec.sh) script is designed to interact with JFrog Xray to retrieve the report specification for a given report name. It first fetches the report ID using the JFrog Xray "Get Reports List" API and then retrieves the  specification using an internal `vulnerabilities/spec` JFrog API.

## Features

- Fetches the report ID for a specified report name.
- Retrieves and displays the vulnerabilities specification for the report.
- Supports parameterized row limit with a default value of 1000.

## Prerequisites

- JFrog Xray must be accessible via the provided `ARTIFACTORY_BASE_URL`.
- A valid JFrog API token (`MYTOKEN`).
- `jq` installed on your system to parse JSON responses.

## Usage

### Basic Usage

```bash
./get_xray_report_spec.sh <ARTIFACTORY_BASE_URL> <MYTOKEN> <REPORT_NAME> [NUM_OF_ROWS]
```

### Parameters

- `ARTIFACTORY_BASE_URL` (required): The base URL of your JFrog Artifactory/Xray instance (e.g., `https://your-artifactory-url`).
- `MYTOKEN` (required): The API token used for authentication.
- `REPORT_NAME` (required): The name of the report for which you want to retrieve the vulnerabilities spec.
- `NUM_OF_ROWS` (optional): The number of rows to fetch from the reports list. Defaults to `1000` if not specified.

### Example

```bash
./get_xray_report_spec.sh "https://your-artifactory-url" "your-jfrog-token" "my-security-report"
```

You can also specify a different number of rows to fetch:

```bash
./get_xray_report_spec.sh "https://your-artifactory-url" "your-jfrog-token" "my-security-report" 500
```

### Output

- The script will print the report ID and the vulnerabilities spec for the specified report.

### Error Handling

- If the specified report name is not found, the script will display an error message and exit.

## Dependencies

- `curl`: To make API requests.
- `jq`: To parse JSON responses.

