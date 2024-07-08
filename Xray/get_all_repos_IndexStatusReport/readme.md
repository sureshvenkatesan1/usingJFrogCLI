How to get xray index status of each  artifacts  in a repository?

Please use the [getIndexStatus.sh](getIndexStatus.sh) script as explained in [getIndexStatus.md](getIndexStatus.md) :
```bash
./getIndexStatus.sh  https://artifactrep.jfrog.io/artifactory <accessToken> <repoKey>
```

---
After the files uploaded to Artifactory, Xray indexing shows only 90% of the files indexed even after 2 days 
after uploading the files .
How do I get a list of files that are not indexed (list of 10% of files that are not indexed) ?

[xrayIndexingReport.sh](xrayIndexingReport.sh) script automates the process of searching for files in an Artifactory repository,
filtering based on the specified repository name and package type, when the artifacts were created , modified or
last downloaded , and generates a report on the indexing status of each of those files in Xray.



Then you can run the script (after giving it executable permissions) with a command like the following.
```
./xrayIndexingReport.sh <artifactoryURL> <MYTOKEN> <repoKey> <repoType> <duration_in_days>
```
This will generate a file called 'indexingStatusReport.txt' . The files that are not indexed (list of 10% of files that 
are not indexed) will have the indexed status as `"Not indexed"`

---
How to identify  the xray index status of all artifacts in a repository and
then run forceReindex on every artifact?

Use the [get_artifact_index_status_and_forceReindex.sh](get_artifact_index_status_and_forceReindex.sh)



```bash
./get_artifact_index_status_and_forceReindex.sh https://artifactory-url username password repository-name

```
After successful execution, a file named `indexingStatusReport.txt` will be created,
If the Xray indexing for a particular repository does not reach 100%, please provide the following details/files for further troubleshooting:

1. **Database Query Output**: Log in to the Postgres DB and execute the following command:
   ```sql
   SELECT * FROM event_states;
   ```
   This will help us verify the status of the indexing process for each artifact.

2. **Indexing Status Report**: Share the complete text file output of `indexingStatusReport.txt`.

3. **Indexed Resources Page Screenshot**: Provide a screenshot of the Indexed Resources page to show the current status of the repository.

4. **Xray Support Bundle**: Share the latest Xray Support Bundle with debug loggers enabled.

---

I want an Index report of all artifacts in a repository. In addition to that if artifacts in the repo  have not been 
indexed or  the retention period “expired” then index only those  artifacts . How can I do that ?
You can use:

a) [get_artifact_index_status_and_forceReindex_with_jf.sh](get_artifact_index_status_and_forceReindex_with_jf.sh) which uses [Force Reindex](https://jfrog.com/help/r/xray-rest-apis/force-reindex)   API.

b) [get_artifact_index_status_and_scannow_with_jf.sh](get_artifact_index_status_and_scannow_with_jf.sh) which uses   [“Scan Now”](https://jfrog.com/help/r/jfrog-rest-apis/scan-now) API ( Enables you to index resources on-demand, even those that were not marked for indexing)

---