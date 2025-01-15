You can search using  JFrog CLI for new artifacts in Artifactory since you last checked using:
- a [FileSpec](https://www.jfrog.com/confluence/display/JFROG/Using+File+Specs) .
See  [Using File Specs](https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/binaries-management-with-jfrog-artifactory/using-file-specs) with JFrog CLI

Example: `jf rt s --spec <xyz.spec>`.

-   [AQL](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Query+Language)  using the
    `/api/search/aql` REST API.

**Note:** When using [AQL](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Query+Language) inside a
[FileSpec](https://www.jfrog.com/confluence/display/JFROG/Using+File+Specs) you cannot specify the attributes to
include in the output . The following attributes will always be included:

`.include("name","repo","path","actual_md5","actual_sha1","sha256","size","type","modified","created","property")`

---
AQL to check the last 5 artifacts in a repo:

```text
curl -u<username> -X POST -k -H 'Content-Type:text/plain' -i "https://jfrog-us.se.com/artifactory/api/search/aql?
compact=true" --data 'items.find({"repo": "<repo-name>"}).sort({"$desc" : ["modified"]}).limit(5)'
```


---
### Find all the artifacts that have were created after 2023-03-23 ( YYY-MM-DD)

```textmate
jf rt curl -s -XPOST /api/search/aql -H 'Content-Type: text/plain' \
-d 'items.find({
    "repo" : "demo-ak-dev-local",
    "$or": [
        {"created": {"$gt": "2022-03-23"}},
        {"modified": {"$gt": "2023-03-23"}}
    ]
})'
```
or

```textmate
jf rt curl -s -XPOST /api/search/aql -H 'Content-Type: text/plain' \
-d 'items.find({
  "repo": "demo-ak-dev-local",
  "$or": [
    {
      "created": {
        "$gt": "2022-03-23T19:20:30.45+01:00"
      }
    },
    {
      "modified": {
        "$gt": "2023-03-23"
      }
    }
  ]
})'
```

---
For non-admin users, the following three fields must be included in the include directive: name, repo, and path.

Otherwise you will see `For permissions reasons AQL demands the following fields: repo, path and name.`
```textmate
jf rt curl -s -XPOST /api/search/aql -H 'Content-Type: text/plain' \
-d 'items.find ({ "repo": "MagicMonitor", "type" : "folder" , "depth" : "3"}, {"path": "MagicVideoPlayerVersionFiveSix/win2016agent"}, {"name": "9"}).include("repo","path","name")'
```

---
Find all artifacts created or modified in last 300 days

You can narrow down the query or expand it by changing the value of the [Relative Time Operator](https://www.jfrog.com/confluence/display/JFROG/Artifactory+Query+Language#ArtifactoryQueryLanguage-RelativeTimeOperators). (i.e. 60m for the 
last 60 minutes or 1mo for the last month)

```textmate
jf rt curl -s -XPOST /api/search/aql -H 'Content-Type: text/plain'  -d 'items.find(
{
  "repo": "demo-ak-dev-local",
  "path": {
    "$match": "*"
  },
  "$or": [
    {
      "created": {
        "$last": "300d"
      }
    },
    {
      "modified": {
        "$last": "300d"
      }
    }
  ]
})' 
```
```textmate
jf rt curl -s -XPOST /api/search/aql -H 'Content-Type: text/plain'  -d 'items.find(
{
  "repo": {
    "$match": "demo-ak-dev-local"
  },
  "name": {
    "$match": "*"
  },
  "$or": [
    {
      "created": {
        "$last": "300d"
      }
    },
    {
      "modified": {
        "$last": "300d"
      }
    }
  ]
})'
```

```textmate
jf rt curl -s -XPOST /api/search/aql -H 'Content-Type: text/plain'  -d 'items.find(
{
  "repo": {
    "$eq": "demo-ak-dev-local"
  }
})'
```

---
https://jfrog.com/help/r/jfrog-artifactory-documentation/comparison-operators
Find all artifacts created or modified greater than a certain datetime and return their full path in the repo:
```
jf rt curl -s -XPOST /api/search/aql -H 'Content-Type: text/plain' \
-d 'items.find({
  "repo": "example-repo-local",
  "$or": [
    {
      "created": {
        "$gt": "2024-01-23T19:20:30.45+01:00"
      }
    },
    {
      "modified": {
        "$gt": "2024-03-23"
      }
    }
  ]
})' --server-id=psazuse | jq -r '.results[]
       | select((.path | test("/_uploads($|/)") | not) and (.path | test("^\\..+") | not))
       | if .path == "." then .name else "\(.path)/\(.name)" end' > cleanpaths0.txt
```
Find all artifacts created or modified within a date range:
```
jf rt curl -s -XPOST /api/search/aql -H 'Content-Type: text/plain' \
-d 'items.find({
  "repo": "example-repo-local",
  "$and": [
          {"$or": [
            {
              "created": {
                "$gt": "2024-01-23T19:20:30.45+01:00"
              }
            },
            {
              "modified": {
                "$lt": "2024-05-27"
              }
            }
          ]},
            {"$or": [
            {
              "created": {
                "$lt": "2024-01-30T19:20:30.45+01:00"
              }
            },
            {
              "modified": {
                "$lt": "2024-05-29"
              }
            }
          ]}

  ]
})' --server-id=psazuse  | jq -r '.results[]
       | select((.path | test("/_uploads($|/)") | not) and (.path | test("^\\..+") | not))
       | if .path == "." then .name else "\(.path)/\(.name)" end' > cleanpaths0.txt
```

If the json out from th aql search was as in [input.json](input.json)
then when you parse the output with `jq` you will get their full path in the repo as in [cleanpaths0.txt](cleanpaths0.txt)

Now if you add few dummy lines   before and after the lines in [cleanpaths0.txt](cleanpaths0.txt) to match the format in [cleanpaths1.txt](cleanpaths1.txt) , you could use  the 
[transfer_cleanpaths_delta_from_repoDiff.py](https://github.com/sureshvenkatesan1/ps_jfrog_scripts/blob/master/jf-transfer-migration-helper-scripts/after_migration_helper_scripts/fix_the_repoDiff/transfer_cleanpaths_delta_from_repoDiff.py) script to migrate these artifacts to another repo in the same or different JPD as:

```
python ps_jfrog_scripts/jf-transfer-migration-helper-scripts/after_migration_helper_scripts/fix_the_repoDiff/transfer_cleanpaths_delta_from_repoDiff.py \
/tmp/cleanpaths1.txt \
psazuse example-repo-local psazuse fab-dev-generic-local
```

---
Finding the last upload to the repo, you can use the "updated" field to sort and find the last uploaded item.
**Note:**
Sort, limit and offset elements only work in the following cases:

If you do have an include element, you only specify fields from the primary domain in it.
```textmate
jf rt curl -s -XPOST /api/search/aql -H 'Content-Type: text/plain'  -d '
items.find({"repo":{"$eq":"example-repo-local"} } ).include("repo", "path", "name", "created", "updated").sort({"$desc" : ["updated"]}).limit(3)'
```

---
For Docker repositories, because of how docker images work you should modify the aql query to search only for 
the manifest.json file and not the individual layers (as clients can skip a layer download if it already 
exists on their local machine).
```textmate
jf rt curl -s -XPOST /api/search/aql -H 'Content-Type: text/plain' -L --server-id=psazuse -d '
items.find({
  "repo": {
    "$eq": "sup016-docker-dev-local"
  },
  "name": {
    "$eq": "manifest.json"
  }
} ).include("repo", "path", "name", "created", "updated").sort({"$desc" : ["updated"]}).limit(3)'
```
Output:
```
{
"results" : [ {
  "repo" : "sup016-docker-dev-local",
  "path" : "my-spring-petclinic/2.0.0",
  "name" : "manifest.json",
  "created" : "2024-05-25T11:43:54.904Z",
  "updated" : "2024-05-25T11:43:54.907Z"
},{
  "repo" : "sup016-docker-dev-local",
  "path" : "my-spring-petclinic/1.0.0",
  "name" : "manifest.json",
  "created" : "2024-05-22T14:33:13.975Z",
  "updated" : "2024-05-22T14:33:13.978Z"
} ],
"range" : {
  "start_pos" : 0,
  "end_pos" : 2,
  "total" : 2,
  "limit" : 3
}
}
```

The above query adds an additional condition to search for the manifest.json file.
You can use that to fetch the docker tags in a docker repo by parsing the output using `|  jq -r '.results[].path'`

That will return:
```
my-spring-petclinic/2.0.0
my-spring-petclinic/1.0.0
```

---
Fetch all metadata / index files in the "." folders i.e .npm , .conan etc

jf rt curl -s  -XPOST "/api/search/aql" -H "Content-Type: text/plain" -L --server-id=psazuse -d 'items.find(
{"repo": "default-docker-local",
"$or": [

                {"path": {"$match": ".*"}}

            ]
        }
    )'

--