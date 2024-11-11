First, make sure to deploy your docker artifact from your CI pipeline ( probably using a  serviceaccount user’s identity or access token). 

```
docker tag b7f59fb1ee85 default-docker-local.example.jfrog.io/generated:1.1

jf rt docker-push default-docker-local.example.jfrog.io/generated:1.1
```

Add additional properties to track the artifact.
```
jf rt set-props "default-docker-local/generated/1.1/*" "test=passed;color=green" --server-id=psazuse
```
Output:
```
17:09:19 [🔵Info] Searching for items in Artifactory...
17:09:20 [🔵Info] Setting properties...
17:09:20 [🔵Info] [Thread 2] Setting properties on: default-docker-local/generated/1.1/sha256__c39070eb3e3af839646b7e1cbe4e34928d70b2193f495a92c4d965024aaecac9
17:09:20 [🔵Info] [Thread 1] Setting properties on: default-docker-local/generated/1.1/sha256__57bd2025381f38d78f8343457ca98a896ba5528a80dcb653b0745b418cfda1d3
17:09:20 [🔵Info] [Thread 0] Setting properties on: default-docker-local/generated/1.1/sha256__aec6c45f36f83b45a4bad71970ad70a65d6c89ab36006c1df86e8c5f1faddb21
17:09:20 [🔵Info] [Thread 0] Setting properties on: default-docker-local/generated/1.1/sha256__d0f42ecf7e6cd9d1b2a6eb22f45ada31d70a854a985ff6a5c24149147bbb6287
17:09:20 [🔵Info] [Thread 2] Setting properties on: default-docker-local/generated/1.1/manifest.json
17:09:20 [🔵Info] Done setting properties.
{
  "status": "success",
  "totals": {
    "success": 5,
    "failure": 0
  }
}
```

Verify  the properties of artifact:
```
jf rt curl -XGET "/api/storage/default-docker-local/generated/1.1/manifest.json?properties" --server-id=psazuse
```

Output:
```
{
  "properties" : {
    "artifactory.content-type" : [ "application/vnd.docker.distribution.manifest.v2+json" ],
    "color" : [ "green" ],
    "docker.manifest" : [ "1.1" ],
    "docker.manifest.digest" : [ "sha256:6aed41d43187f94e2bcab5ed0b3f1d53ba20b2f2076a2e261bb11bbab8846491" ],
    "docker.manifest.type" : [ "application/vnd.docker.distribution.manifest.v2+json" ],
    "docker.repoName" : [ "generated" ],
    "oci.artifact.type" : [ "application/vnd.docker.container.image.v1+json" ],
    "sha256" : [ "6aed41d43187f94e2bcab5ed0b3f1d53ba20b2f2076a2e261bb11bbab8846491" ],
    "test" : [ "passed" ]
  },
  "uri" : "https://psazuse.jfrog.io/artifactory/api/storage/default-docker-local/generated/1.1/manifest.json"
}
```
---

[CLI for JFrog Distribution](https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-distribution)

### CREATE RELEASE BUNDLE

See example spec in  [rbv1_create_json_examples/create-rc-file-property-test_and_color.json](rbv1_create_json_examples/create-rc-file-property-test_and_color.json)
```
jf ds rbc --spec=create-rc-file-property-test_and_color.json rb_swamp 1.0.0 --desc="release candidate" --server-id=psazuse
```

### SIGN RELEASE BUNDLE

```
jf ds rbs rb_swamp 1.0.0 --detailed-summary=true --passphrase=<your_passphrase> --server-id=psazuse
```
Output:
```
{
  "status": "success",
  "totals": {
    "success": 1,
    "failure": 0
  },
  "files": [
    {
      "sha256": "ea520dcf068175e97451c43fc31a4df1a38db0c0b87c3ac6ad6bd63a1ed4157f"
    }
  ]
}
```

### DISTRIBUTE RELEASE BUNDLE

```
jf ds rbd --dist-rules=dist-rules.json rb_swamp 1.0.0 --create-repo=true --server-id=psazuse

Output:
17:04:48 [🔵Info] Distributing: rb_swamp/1.0.0
```
Note: update [rbv1_distribute_to_edge_json_examples/dist-rules.json](rbv1_distribute_to_edge_json_examples/dist-rules.json) with the  edge you want to distribute to.

If you specify the `"auto_create_missing_repositories": true` as in [rbv1_distribute_to_edge_json_examples/distribute.json](rbv1_distribute_to_edge_json_examples/distribute.json) you don't have to use `--create-repo=true` .


###  Check artifacts in the Release bundle v1
If you want to know the artifacts in the release bundle received by a JPD or edge node , it can be done using  REST API [Get a release bundle version](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#ArtifactoryRESTAPI-Getareleasebundleversion) .

?format=json
```
jf rt curl -XGET  "api/release/bundles/rb_swamp/1.0.0" --server-id=psazeuwedge | json_pp


```

Output:
```
{
   "artifacts" : [
      {
         "checksum" : "c39070eb3e3af839646b7e1cbe4e34928d70b2193f495a92c4d965024aaecac9",
         "props" : [
            {
               "key" : "sha256",
               "values" : [
                  "c39070eb3e3af839646b7e1cbe4e34928d70b2193f495a92c4d965024aaecac9"
               ]
            }
         ],
         "repo_path" : "default-docker-local/generated/1.1/sha256__c39070eb3e3af839646b7e1cbe4e34928d70b2193f495a92c4d965024aaecac9"
      },
      {
         "checksum" : "d0f42ecf7e6cd9d1b2a6eb22f45ada31d70a854a985ff6a5c24149147bbb6287",
         "props" : [
            {
               "key" : "sha256",
               "values" : [
                  "d0f42ecf7e6cd9d1b2a6eb22f45ada31d70a854a985ff6a5c24149147bbb6287"
               ]
            }
         ],
         "repo_path" : "default-docker-local/generated/1.1/sha256__d0f42ecf7e6cd9d1b2a6eb22f45ada31d70a854a985ff6a5c24149147bbb6287"
      },
      {
         "checksum" : "57bd2025381f38d78f8343457ca98a896ba5528a80dcb653b0745b418cfda1d3",
         "props" : [
            {
               "key" : "sha256",
               "values" : [
                  "57bd2025381f38d78f8343457ca98a896ba5528a80dcb653b0745b418cfda1d3"
               ]
            }
         ],
         "repo_path" : "default-docker-local/generated/1.1/sha256__57bd2025381f38d78f8343457ca98a896ba5528a80dcb653b0745b418cfda1d3"
      },
      {
         "checksum" : "aec6c45f36f83b45a4bad71970ad70a65d6c89ab36006c1df86e8c5f1faddb21",
         "props" : [
            {
               "key" : "sha256",
               "values" : [
                  "aec6c45f36f83b45a4bad71970ad70a65d6c89ab36006c1df86e8c5f1faddb21"
               ]
            }
         ],
         "repo_path" : "default-docker-local/generated/1.1/sha256__aec6c45f36f83b45a4bad71970ad70a65d6c89ab36006c1df86e8c5f1faddb21"
      },
      {
         "checksum" : "6aed41d43187f94e2bcab5ed0b3f1d53ba20b2f2076a2e261bb11bbab8846491",
         "props" : [
            {
               "key" : "artifactory.content-type",
               "values" : [
                  "application/vnd.docker.distribution.manifest.v2+json"
               ]
            },
            {
               "key" : "docker.manifest",
               "values" : [
                  "1.1"
               ]
            },
            {
               "key" : "sha256",
               "values" : [
                  "6aed41d43187f94e2bcab5ed0b3f1d53ba20b2f2076a2e261bb11bbab8846491"
               ]
            },
            {
               "key" : "oci.artifact.type",
               "values" : [
                  "application/vnd.docker.container.image.v1+json"
               ]
            },
            {
               "key" : "docker.repoName",
               "values" : [
                  "generated"
               ]
            },
            {
               "key" : "docker.manifest.digest",
               "values" : [
                  "sha256:6aed41d43187f94e2bcab5ed0b3f1d53ba20b2f2076a2e261bb11bbab8846491"
               ]
            },
            {
               "key" : "docker.manifest.type",
               "values" : [
                  "application/vnd.docker.distribution.manifest.v2+json"
               ]
            }
         ],
         "repo_path" : "default-docker-local/generated/1.1/manifest.json"
      }
   ],
   "created" : "2024-11-10T00:57:21.204+0000",
   "description" : "release candidate",
   "name" : "rb_swamp",
   "version" : "1.0.0"
}
```



---
References:

[SUP016-Automate_everything_with_the_JFrog_CLI/lab-7](https://github.com/jfrog/SwampUp2022/tree/main/SUP016-Automate_everything_with_the_JFrog_CLI/lab-7) 
