How to find the repo from which an artifact is getting reoslved when searching in a virtual repository?

Search the file from the virtual repo `manu-generic-all` using AQL :
```
curl -H "Authorization: Bearer token"  -X POST "https://incloudmaster.jfrog.io/artifactory/api/search/aql" -H "Content-Type: text/plain" -d 'items.find({
  "repo": {
    "$eq": "manu-generic-all"
  },
  "type": "file",
  "name": {
    "$match": "test3.zip"
  }
}).include("name", "repo", "path", "created", "size")' 
```

Output shows the artifact is served from the `manu3-snapshot-generic` repo as that is first in the 
aql result:
```
{
"results" : [ {
  "repo" : "manu3-snapshot-generic",
  "path" : ".",
  "name" : "test3.zip",
  "size" : 9147411,
  "created" : "2025-04-06T20:01:42.630Z"
},{
  "repo" : "manu3-release-generic",
  "path" : ".",
  "name" : "test3.zip",
  "size" : 9147411,
  "created" : "2025-04-06T20:01:55.653Z"
} ],
"range" : {
  "start_pos" : 0,
  "end_pos" : 2,
  "total" : 2,
  "limit" : 500000
}
}
```
---
