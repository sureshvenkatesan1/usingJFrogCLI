How to get xray index status of each  artifacts  in a repository?
[154987](https://groups.google.com/a/jfrog.com/g/support-followup/c/jbR6DyB-Y_8/m/j2SuFdFuAwAJ)
Reference:  [xrayRepoIndexingStatus.sh](https://git.jfrog.info/projects/SUP/repos/scripts/browse/xrayRepoIndexingStatus/xrayRepoIndexingStatus.sh)  
Run:
```bash
./getIndexStatus.sh  https://artifactrep.jfrog.io/artifactory <admin-user> <admin-password> <name_of_repository>
```
---
After the files uploaded to Artifactory, Xray indexing shows only 90% of the files indexed even after 2 days 
after uploading the files .
How do I get a list of files that are not indexed (list of 10% of files that are not indexed) ?

>> xrayIndexingReport.sh script automates the process of searching for files in an Artifactory repository, filtering based on
the specified repository name and type , Xray indexing retention period for the repo  , and generates a
report on  the indexing  status of each of those files in Xray.

Make sure you have the following environmental variable set:
$ARTIFACTORY_URL ( example https://example.jfrog.io )
$ARTIFACTORY_USERNAME
$ARTIFACTORY_PASSWORD

Then you can run the script (after giving it executable permissions) with a command like the following.
```
./xrayIndexingReport.sh libs-local-generic-tml generic 90
```
This will generate a file called 'indexingStatusReport.txt' which will give list of files that are not indexed (list of 10% of files that are not indexed)

---
Execute the below script which will help to identify  the xray index status of all artifacts in a repository and
then run forceReindex on each artifact.


>>You many need to provide read/write/executable permissions (chmod 777 get_artifact_index_status_and_forceReindex.sh)

use below format: after successful execution, a file named indexingStatusReport.txt will be created,

```bash
./get_artifact_index_status_and_forceReindex.sh https://artifactory-url username password repository-name

```
Once executing, please share the below details/files with us for further troubleshooting.

1. Login to the Postgres DB and execute the following command ( select * from event_states ). We would like to verify the status of the indexing process on each artifact.

2. Output of indexingStatusReport.txt file. Please share the complete text file with us.

3. Screenshot of Indexed Resources page ( to know the current status of ‘fedramp-release’ repository )

4. Latest Xray Support Bundle ( with debug loggers enabled ).
---
