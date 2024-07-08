
# Xray Indexing Status Report Script

[getIndexStatus.sh](getIndexStatus.sh) script , generates a report of Xray indexing statuses for all files in a specified 
  Artifactory   repository.

## Prerequisites

- JFrog Artifactory
- JFrog Xray
- `jq` (a lightweight and flexible command-line JSON processor)

## Usage

### Command

```bash
./getIndexStatus.sh <artifactoryURL> <accessToken> <repoKey>
```

### Parameters

- `artifactoryURL`: The URL of your Artifactory instance (e.g., `http://example.jfrog.io/artifactory`).
- `accessToken`: Your Artifactory username.
- `repoKey`: The key of the repository you want to check (e.g., `nuget-local`).

### Example

```bash
./getIndexStatus.sh http://example.jfrog.io/artifactory $MYTOKEN nuget-local
```

## How It Works

1. The script fetches the list of all files in the specified repository using the Artifactory REST API.
2. It saves the list of file URIs to a temporary file (`filesList.txt`).
3. For each file, it retrieves the Xray indexing status using the Xray REST API.
4. It writes the file URIs and their corresponding Xray indexing statuses to `indexingStatusReport.txt`.
5. Finally, it cleans up the temporary file.

## Output

The output file `indexingStatusReport.txt` will contain lines in the following format:

```
<file-uri>    <xray-index-status>
```

Where:
- `<file-uri>` is the URI of the file within the repository.
- `<xray-index-status>` is the indexing status reported by Xray.

For example:
```
/a/chris/demo/0.0.2-SNAPSHOT/demo-0.0.2-20240607.231951-1.jar	High
/a/chris/demo/0.0.2-SNAPSHOT/demo-0.0.2-20240607.231951-1.pom	Not indexed
/a/chris/demo/0.0.2-SNAPSHOT/maven-metadata.xml	Not indexed
/a/chris/demo/maven-metadata.xml	Not indexed
/org/yann/demo/0.0.1-SNAPSHOT/demo-0.0.1-20240606.191008-1.jar	Scanned - No Issues
```

## Cleanup

The script removes the temporary `filesList.txt` file after processing.

## Notes

- Ensure that the provided credentials have the necessary permissions to access the repository and Xray.
- The `jq` utility must be installed and available in your system's PATH.

Reference:
From [xrayRepoIndexingStatus.sh](https://git.jfrog.info/projects/SUP/repos/scripts/browse/xrayRepoIndexingStatus/xrayRepoIndexingStatus.sh)   mentioned in [154987](https://groups.google.com/a/jfrog.com/g/support-followup/c/jbR6DyB-Y_8/m/j2SuFdFuAwAJ) 
