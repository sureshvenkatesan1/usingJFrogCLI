
# Xray Indexing Report Script

This [xrayIndexingReport.sh](xrayIndexingReport.sh) script automates the process of searching for files in an Artifactory repository, 
filtering based on the specified repository name and package type, when the artifacts were created , modified or 
last downloaded , and generates a report on the indexing status of each of those files in Xray.

## Prerequisites

- JFrog Artifactory
- JFrog Xray
- `jq` (a lightweight and flexible command-line JSON processor)

## Usage

### Command

```bash
./xrayIndexingReport.sh <artifactoryURL> <MYTOKEN> <repoKey> <repoType> <duration_in_days>

```

### Parameters

- `artifactoryURL`: The URL of the Artifactory instance.
- `MYTOKEN`: The authentication token for accessing Artifactory.
- `repoKey`: The key of the repository to search in.
- `repoType`: The type of package to search for.
- `duration_in_days`: The created , modified or last downloaded duration in days for the files.

### Example

```bash
./xrayIndexingReport.sh "https://artifactory.example.com" "your_token_here" "example-repo" "maven" 30

```

## How It Works

- **Fetch Supported Package Types**: Retrieves a list of supported package types from the Artifactory Xray API and filters the list to include package types that match the specified `repoType` and have a file extension.
- **Construct AQL Query**: Uses the filtered list of extensions to create an AQL filter and constructs an AQL query to search for files in the specified repository that were created, modified, or downloaded within the specified duration.
- **Retrieve File List**: Sends the AQL query to the Artifactory AQL search API to retrieve a list of matching files and parses the results to extract the file paths and names.
- **Generate Indexing Status Report**: Loops through each file in the list and retrieves the Xray indexing status of the file, appending the status to a report file.
- **Cleanup**: Deletes the temporary file containing the list of file paths.

## Output

The output file `indexingStatusReport.txt` will contain lines in the following format:

```
<file-path>    <xray-index-status>
```

Where:
- `<file-path>` is the path of the file within the repository.
- `<xray-index-status>` is the indexing status reported by Xray.

## Notes

- The `jq` utility must be installed and available in your system's PATH.
- The provided credentials must have the necessary permissions to access the repository and Xray.

