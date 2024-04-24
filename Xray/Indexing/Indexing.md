
How to run the "index now" button that is in the Xray UI, from the API ?
```text
curl -XPOST  -uadmin:<password> '<JFROG_PLATFORM_URL>/xray/ui/unified/indexBinMgrWithFilter'   --data-raw '{"repos":["<repo_name>"],"filter":{"include_pattern":"**","exclude_pattern":""}}'
```
---
## Index artifacts
To run the same  "index now" for artifacts not indexed for last 10 days ?
```text
curl -XPOST  -uadmin:<password> '<JFROG_PLATFORM_URL>/xray/ui/unified/indexBinMgrWithFilter'   --data-raw '{"repos":
["<repo_name>"],"filter":{"include_pattern":"**","exclude_pattern":"","time_range":"10d"}}'
```
Output:
```text
{"info":"index of binary manager:default is in progress"}
```

Logs the following in the `xray-indexer-service.log`:
```text
2022-03-24T21:00:40.596Z [33m[jfxid][0m [34m[INFO ][0m [44d76f7888a4216b] [downloader:75         ] [main        ] Event worker id 1 is processing message from index --> repo maven-central-local-safe-prod
```
---
## Index release bundle

Script to index/scan each artifact in a release bundle:
[211812](https://jfrog.lightning.force.com/lightning/r/EmailMessage/02s6900002io63OAAQ/view)
```text
#!/bin/bash
curl -u user:password1 -X GET "https://source.artifactory/distribution/api/v1/release_bundle/<insert bundle name here>/LATEST?format=json" | jq -r '.artifacts[] | .targetRepoPath' > files-bundle.txt
while read -r line; do
curl https://destination.artifactory/xray/api/v2/index -u user:password2 -XPOST -d '{"repo_path":"'"$line"'"}' -H "content-type: application/json"
done < files-bundle.txt
rm files-bundle.txt
```

---
## The Binary Manager
How to find the binary manager i.e Artifactory ID to use with [Get Binary Manager](https://jfrog.com/help/r/xray-rest-apis/get-binary-manager)  API ?
i.e What is the {ID} in `GET /api/v1/binMgr/{id}` ?

The {id} variable pertains to the id of the binary manager (Artifactory) which can be retrieved via the
[Get Binary Manager](https://jfrog.com/help/r/xray-rest-apis/get-binary-manager)  API as follows using `jq`:

```text
jf xr curl "/api/v1/binMgr" --server-id soleng -s | jq -r '.[].binMgrId' | sort | uniq
```
The `jq` parses the below json and will give the id of the binary manager as shown below:
```
[{"binMgrId":"default","binMgrUrl":"http://localhost:8046/artifactory","license_valid":true,"id":"dec445ed-df72-4aa1-8687-3279da4a6473","version":"7.64.7","indexed_builds":[{"name":"npm_build"}]}]
```

Output:
```text
default
```

---
## Repos:
Find all repos indexed by Xray:
YOu can  use the '[Get Repos Indexing Configuration](https://jfrog.com/help/r/jfrog-rest-apis/get-repos-indexing-configuration)' API
which Gets the indexed and not indexed repositories in a given binary manger and filter for indexed repos using jq
as mentioned in KB
[Generate Report With All Repositories Included Using REST API](https://jfrog.com/help/r/xray-generate-report-with-all-repositories-included-using-rest-api)
:
```text
jf xr curl -XGET "/api/v1/binMgr/default/repos" --server-id soleng |jq '.indexed_repos | map({name: .name})'
```

Running the above will output a list of  repositories indexed by Xray:

```text
[
  {
    "name": "repo1"
  },
  {
    "name": "repo2"
  }
]
```
---

What is the rest api to index a repo that is not already indexed for Xray scans?
If your use case is to add the repository to the indexed list, I would recommend using the REST API to update the
repository configuration as mentioned in [Update Repository Configuration](https://jfrog.com/help/r/jfrog-rest-apis/update-repository-configuration)  API.
In short:
1. Create a json file having the below entry for xrayIndex and set it to true.
```text   
{
   "xrayIndex" : true
}
```
2. Now, run the REST API to update the repository configuration and you will see that the repository will be added to the list of Indexed repositories. Below is the example from our lab for your reference:-
```text 
jf rt curl -XPOST "/api/repositories/<repo-name>"  -H "Content-Type: application/json" -T repo.json  
```  
Output:
`Repository <repo-name> update successfully.`

---
I want to reindex all the repos ( that have "Enable Indexing In Xray" i.e xrayIndex  enabled ) in my artifactory for 
enabling full XRAY scan . I don't want to do it repo by repo manually. How to do it ?

First, you should get names of indexed repositories via the following API call.
```text
jf xr cl /api/v1/binMgr/{id}/repos | jq  '.indexed_repos[] | .name'
```

Then index each repository from the list:
```text
jf xr cl  -XPOST  -H "content-type:application/json" /api/v1/index/repository/<repository_name>
```

For your convenience see the script [reindex_repos_enabled_for_xray_indexing.sh](reindex_repos_enabled_for_xray_indexing.sh)

---
## Builds
Get all the builds in the  Artifactory ( the binary manager)  :
```text
jf xr curl "/api/v1/binMgr/default/builds"
```

Output:
```text
{"bin_mgr_id":"default","indexed_builds":["npm_build"],"non_indexed_builds":[]}
```
---
[Add Builds to Indexing Configuration](https://jfrog.com/help/r/xray-rest-apis/add-builds-to-indexing-configuration)
```text
curl -XPOST -u admin:password https://servername.jfrog.io/xray/api/v1/binMgr/builds -H 'content-type:application/json' -d '{"names": ["build-name"]}' -vvv

or

jf xr curl -XPOST api/v1/binMgr/builds -H 'content-type:application/json' -d '{"names": ["npm_build"]}'
```
Output:
{"info":"Builds Names has been successfully set to index"}

---
Get all the builds `indexed` by Artifactory ( the binary manager) :


```text
#!/bin/bash

# Check if the server ID argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <server-id>"
    exit 1
fi

server_id=$1

# Get the indexed builds
indexed_builds=$(jf xr curl "/api/v1/binMgr/default/builds" --server-id "$server_id" -s | jq -r '.indexed_builds[]')

echo "Indexed Builds:"
echo "$indexed_builds"

```
Sample Output:
```text
Android CI
java-build
gh-ejs-demo
```
---




