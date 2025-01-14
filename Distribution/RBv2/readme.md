Please review [Understanding Release Bundles v2](https://jfrog.com/help/r/jfrog-artifactory-documentation/understanding-release-bundles-v2)

A new Release Bundle can be created in several ways, including from builds, individual artifacts, AQL queries, or existing Release Bundles.

The basic workflow for using Artifactory for Release Lifecycle Management is described in  [Release Lifecycle Management Workflow](https://jfrog.com/help/r/jfrog-artifactory-documentation/release-lifecycle-management-workflow) 

Also review the KB article [ARTIFACTORY: How to create a Release Bundle V2](https://jfrog.com/help/r/artifactory-how-to-create-a-release-bundle-v2/artifactory-how-to-create-a-release-bundle-v2)

Example of generating Release Bundle v2 (RBv2) from a Maven build (whose buildInfo is published to Artifactory) using Jfrog CLI can be found in https://github.com/DayOne-Dev/spring-petclinic/blob/main/my-files/scripts-sh/jf-cli-mvn-rbv2.sh.

Please review the [Pipeline: Flow Diagrams](https://github.com/DayOne-Dev/spring-petclinic/blob/main/my-files/readme.md#pipeline-flow-diagrams) which shows how to use RBv2 workflow for a Docker build  .


This guide outlines some of the steps required for creating and distributing a Release Bundle v2 in JFrog Platform.

### 1. Generate and upload signing keys to Artifactory
First generate a GPG key that will be used to sign the Release Bundle and upload it to the JFrog Platform as mentioned in [generate_rbv2_gpg_key.md](generate_rbv2_gpg_key.md)




### 2. Propagate Public Signing Key to Edge Nodes
[Propagate Public Signing Key](https://jfrog.com/help/r/jfrog-rest-apis/propagate-public-signing-key)

Propagate the signing key to edge nodes using REST API:

```bash
# Set your JFrog Platform access token (replace with your token)
export MYTOKEN=your_access_token_here

# Using REST API
curl -i -XPOST "http://<ARTIFACTORY_URL>/lifecycle/api/v2/distribution/key/propagate/jfrog_rbv2_key1" \
    -H "Authorization: Bearer $MYTOKEN"
```

### 3. Create and Sign Release Bundle v2
[Create and sign release bundle v2](https://jfrog-int.atlassian.net/wiki/spaces/CT/pages/640025058/How+to+create+release+bundle+v1+v2+and+to+download+it+with+connect#Upload-and-propagate-GPG-signing-keys-for-distribution-v2)

#### Using AQL Source Type:
[Source Type - AQL](https://jfrog.com/help/r/jfrog-rest-apis/source-type-aql)
```bash
curl -i -k -X POST "http://<ARTIFACTORY_URL>/lifecycle/api/v2/release_bundle?async=false" \
    --header "X-JFrog-Signing-Key-Name: jfrog_rbv2_key1" \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $MYTOKEN" \
    --data '{
        "release_bundle_name": "Gradle-Dist",
        "release_bundle_version": "1",
        "source_type": "aql",
        "source": {
            "aql": "items.find({\"$and\" : [{\"repo\": {\"$match\": \"*example-repo-local*\"}}, {\"name\": {\"$match\": \"*\"}}]})"
        },
        "skip_docker_manifest_resolution": false
    }'
```
Note: The "skip_docker_manifest_resolution" is explained in [Release Bundles v2 and Docker Manifests](https://jfrog.com/help/r/jfrog-artifactory-documentation/release-bundles-v2-and-docker-manifests)

#### Using Artifacts Source Type:
[Source Type - Artifacts](https://jfrog.com/help/r/jfrog-rest-apis/source-type-artifacts)
```bash
curl -i -k -X POST "http://<ARTIFACTORY_URL>/lifecycle/api/v2/release_bundle?project=default&async=false" \
    --header "X-JFrog-Signing-Key-Name: jfrog_rbv2_key1" \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $MYTOKEN" \
    --data '{
        "release_bundle_name": "v2bundle_1",
        "release_bundle_version": "1.1",
        "source_type": "artifacts",
        "source": {
            "artifacts": [
                {
                    "path": "example-repo-local/File.jpg",
                    "sha256": "a39def45c58010f7ba385739d61c7a145335f0776c1f36e25b23f4d450d803d0"
                }
            ]
        }
    }'
```
In this way you can create a RBv2 for  Docker image (that is already in Artifactory) as mentioned in [RTFACT-30794](https://jfrog.atlassian.net/browse/RTFACT-30794) i.e
```
curl -i -k -X POST "http://<ARTIFACTORY_URL>/lifecycle/api/v2/release_bundle?project=default&async=false" \
    --header "X-JFrog-Signing-Key-Name: jfrog_rbv2_key1" \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $MYTOKEN" \
    --data '{
        "release_bundle_name": "test-bassel",
        "release_bundle_version": "3.0.0",
        "skip_docker_manifest_resolution": false,
        "source_type": "artifacts",
        "source": {
            "artifacts": [
                {
                    "path": "<repo>/<path>/manifest.json",
                    "sha256": "<the sha 256 of the manifest.json>"
                }
            ]
        }
    }'

```

### 3. Check Release Bundle Status

```bash
curl -i -k -X GET "http://<ARTIFACTORY_URL>/lifecycle/api/v2/release_bundle/statuses/v2bundle_1/1.1" \
    --header "Authorization: Bearer $MYTOKEN"
```

### 4. Distribute Release Bundle

#### To All Edges (Using JFrog CLI):
```bash
jf rbd Gradle-Dist 1
```

#### To Specific Edge (Using REST API):

Note: If the Release Bundle v2 version belongs to a specific project, you must specify either the repository_key or the project
```bash
curl -i -k -X POST "http://<ARTIFACTORY_URL>/lifecycle/api/v2/distribution/distribute/v2bundle_1/1.1?repository_key=release-bundles-v2" \
    --header "Authorization: Bearer $MYTOKEN" \
    --header "Content-Type: application/json" \
    --data '{
        "auto_create_missing_repositories": "false",
        "distribution_rules": [
            {
                "site_name": "pseuedge"
            }
        ],
        "modifications": {
            "default_path_mapping_by_last_promotion": false,
            "mappings": [
                {
                    "input": "(.*)/(.*)",
                    "output": "$1/mapping/$2"
                }
            ]
        }
    }'
```

### 5. Delete Operations

#### Delete Release Bundle from Edge Nodes i.e remote deletion from the Mothership
```bash
# Using JFrog CLI
jf rbdelr v2bundle_1 1.1 --server-id=<server-id>

# Using REST API
curl -i -k -X POST "http://<ARTIFACTORY_URL>/lifecycle/api/v2/distribution/remote_delete/v2bundle_1/1.1" \
    --header "Authorization: Bearer $MYTOKEN" \
    --header "Content-Type: application/json" \
    --data '{
        "distribution_rules": [
            {
                "site_name": "*"
            }
        ]
    }'
```

#### Delete Release Bundle Version Locally:
[Delete Release Bundle v2 Version](https://jfrog.com/help/r/jfrog-rest-apis/delete-release-bundle-v2-version)
```bash
# Using JFrog CLI
jf rbdell v2bundle_1 1.1

# Using REST API
curl -i -k -X DELETE "http://<ARTIFACTORY_URL>/lifecycle/api/v2/release_bundle/records/Gradle-Dist/1" \
    --header "Authorization: Bearer $MYTOKEN"
```
Note: 
 When deleting release bundles:
   - Local deletion (`rbdell`) removes the bundle and its promotions only locally
   - Remote deletion (`rbdelr`) removes the bundle from edge nodes
   - If the bundle is already deleted from the mothership, trying to delete it locally from the edge will result in an error as operations might not be available with Edge license
```
14:53:30 [🟠Warn] The server response: 501 Not Implemented
{
  "errors": [
    {
      "status": 501,
      "message": "Part of Release Lifecycle features are not available with Edge license."
    }
  ]
}
```
