Process the output from https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#ArtifactoryRESTAPI-GetStorageSummaryInfo
using [storageSummer.py](https://git.jfrog.info/projects/SUP/repos/storagesummer/browse/storageSummer.py) from @Patrick
```
curl  -XGET '$PROTOCOL://$MYSERVERHOST_IP/artifactory/api/storageinfo' --header 'Authorization: Bearer $MYTOKEN'
```

Example:
```
curl -n -XGET 'http://35.230.109.179/artifactory/api/storageinfo'   > storage-summary.json
curl -n -XGET 'http://34.139.183.161/artifactory/api/storageinfo'   > storage-summary-161.json

```

Usage:
```
python ./storageSummer.py --printEmpty storage-summary.json
python ./storage_summary_diff.py
```
---
[File Statistics](https://jfrog.com/help/r/jfrog-rest-apis/file-statistics)
Is there a way to retain the "number of downloads" metadata when moving an artifact from a remote cache to a local repository?

You can extract the download details using the [JFrog REST API for file statistics](https://jfrog.com/help/r/jfrog-rest-apis/file-statistics) and add them as properties to the artifacts in the target repository. However, there is no API to automatically retain the "number of downloads" as implicit metadata in the target repository.
```text
jf rt curl -XGET "/api/storage/alpha-npm-dev-local/npm-example-1.1.0.tgz?stats" --server-id=soleng
```

Output:
```text
{
  "uri" : "https://example.jfrog.io/artifactory/alpha-npm-dev-local/npm-example-1.1.0.tgz",
  "downloadCount" : 5,
  "lastDownloaded" : 1705081737081,
  "lastDownloadedBy" : "john",
  "remoteDownloadCount" : 0,
  "remoteLastDownloaded" : 0
}
```