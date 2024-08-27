# List all artifacts in a repo:

## using aql
From
[Concat 2 fields in JSON using jq](https://stackoverflow.com/questions/37710718/concat-2-fields-in-json-using-jq)

[Using jq to concatenate multiple entries into a single string value?](https://stackoverflow.com/questions/68022774/using-jq-to-concatenate-multiple-entries-into-a-single-string-value)

[jq + how to print only the value of key under properties](https://unix.stackexchange.com/questions/460059/jq-how-to-print-only-the-value-of-key-under-properties)

For a local repo:
```
jf rt curl -s -XPOST /api/search/aql -H 'Content-Type: text/plain' -d 'items.find({"$or":[{"$and":[{"repo":"mvn-fed-local","path":{"$match":"*"},"name":{"$match":"*"}}]}]}).include("name","repo","path")' | jq ' .results[] | {url: (.repo + "/" + .path + "/" + .name)}' | jq  -r '.url'
```
[How to quickly return all artifacts and their properties in an Aritfactory repo?](https://stackoverflow.com/questions/64380004/how-to-quickly-return-all-artifacts-and-their-properties-in-an-aritfactory-repo)

```text
jf rt s mvn-fed-local
jf rt s mvn-fed-local --count

```

For a remote repo cache:
```
jf rt curl -s -XPOST /api/search/aql -H 'Content-Type: text/plain' -d 'items.find({"$or":[{"$and":[{"repo":"sup016-maven-remote-cache","path":{"$match":"*"},"name":{"$match":"*"}}]}]}).include("name","repo","path")' | jq ' .results[] | {url: (.repo + "/" + .path + "/" + .name)}' | jq  -r '.url'
```
You can further sort them using:
```text
jf rt curl -s -XPOST /api/search/aql -H 'Content-Type: text/plain' -d 'items.find({"$or":[{"$and":[{"repo":"sup016-maven-remote-cache","path":{"$match":"*"},"name":{"$match":"*"}}]}]}).include("name","repo","path")' | jq ' .results[] | {url: (.repo + "/" + .path + "/" + .name)}' | jq  -r '.url' | sort -k1rn
```
Find artifacts named with a suffix pattern in repo that are under a specified path pattern:
```sql
jf rt curl -s -XPOST /api/search/aql -H 'Content-Type: text/plain'  -d 'items.find({ "repo": "local-goldimages-legacy-generic-aws-us-east-1", "path": { "$match": "http:/*" }, "name": { "$match": "*filelists.xml.gz" } }).include("repo", "path", "name", "size", "actual_sha1", "sha256", "created", "modified", "updated", "created_by", "modified_by", "stat.downloaded", "stat.downloads")'
```

Support tickets search: "aql" + "limit" + "offset" + "find"

If there are some 150 items, if we specify the offset as 100 and the limit as 50 like below then it will try to display only the last 50 items and I believe it may help you in identifying the end and if there are no results then it denotes the end of the items.

Sample query:
```aidl
curl -u user:password -H "Content-Type: text/plain" -X POST https://artifactory.jfrog.io/artifactory/api/search/aql -d 
'items.find({"modified" : {"$last" : "10d"}}).offset(100).limit(50)'
```

---

## List all files and folders using `storage` api :
```text
jf rt curl -XGET "/api/storage/example-repo-local/?list&deep=1&listFolders=1&mdTimestamps=1&statsTimestamps=1&includeRootPath=1"
jf rt curl -XGET "/api/storage/example-repo-local?list&deep=1&listFolders=1&mdTimestamps=1"
```
---
### How to use jq to change the following output of a list of files in a repo 
```
jf rt curl -XGET "/api/storage/example-repo-local?list&deep=1&listFolders=0&mdTimestamps=1" --server-id psazuse
```
i.e
```
{
  "uri": "https://psazuse.jfrog.io/artifactory/api/storage/example-repo-local",
  "created": "2024-08-20T23:08:59.007Z",
  "files": [
    {
      "uri": "/DevOps-Patterns-Practices-Examples/10215/RAD Americas Workbench/20230811.15/CodePointIM.jar",
      "size": 11792,
      "lastModified": "2024-06-10T05:08:18.788Z",
      "folder": false,
      "sha1": "7d6b19c4763ea04b0493190e5dd3763b5ebe7490",
      "sha2": "ade67dabae91c100fd94ee6db3eb3704f2e9d0acbc2478adea5dec28da72c3ea",
      "mdTimestamps": {
        "properties": "2024-06-10T05:08:19.817Z"
      }
    },
    {
      "uri": "/DevOps-Patterns-Practices-Examples/10215/RAD Americas Workbench/20230811.15/FileChooserDemo.jar",
      "size": 11792,
      "lastModified": "2024-06-10T05:08:19.681Z",
      "folder": false,
      "sha1": "7d6b19c4763ea04b0493190e5dd3763b5ebe7490",
      "sha2": "ade67dabae91c100fd94ee6db3eb3704f2e9d0acbc2478adea5dec28da72c3ea",
      "mdTimestamps": {
        "properties": "2024-06-10T05:08:20.723Z"
      }
    }
  ]
}
```
to
```
{
  "uri": "https://psazuse.jfrog.io/artifactory/api/storage/example-repo-local",
  "created": "2024-08-20T23:08:59.007Z",
  "files": [
    {
      "uri": "/example-repo-local/DevOps-Patterns-Practices-Examples/10215/RAD Americas Workbench/20230811.15/CodePointIM.jar",
      "size": 11792,
      "lastModified": "2024-06-10T05:08:18.788Z",
      "folder": false,
      "sha1": "7d6b19c4763ea04b0493190e5dd3763b5ebe7490"
    }
  ]
}
```

>> To achieve the transformation you want using jq, you need to adjust the files array, modifying the uri values to 
 include the repository name at the beginning and removing the sha2 and mdTimestamps fields. 
> 
Here's how you can do that:
```
jf rt curl -XGET "/api/storage/example-repo-local?list&deep=1&listFolders=0&mdTimestamps=1" --server-id psazuse | jq '
 {
   "uri": .uri,
   "created": .created,
   "files": [
 	.files[] | {
   	"uri": "/example-repo-local\(.uri)",
   	"size": .size,
   	"lastModified": .lastModified,
   	"folder": .folder,
   	"sha1": .sha1,
"sha2": .sha2
 	}
   ]
 }'

```
---



