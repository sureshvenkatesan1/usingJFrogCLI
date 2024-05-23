All APIs are in https://jfrog.com/help/r/jfrog-rest-apis/release-bundles-v1

1. Create GPG key and upload it Distribution and propagate to all the nodes
```
   curl -u $MYUSER:$MYPASSWORD -H "Accept: application/json" -H "Content-Type: application/json" -X POST  "$PROTOCOL://$MYSERVERHOST_IP/distribution/api/v1/keys/gpg" -T 2ndkey.json
```
2. Create RB through API
```
   curl -u $MYUSER:$MYPASSWORD -H "Accept: application/json" -H "Content-Type: application/json" -H "X-GPG-PASSPHRASE: $PASSPHRASE" -X POST "$PROTOCOL://$MYSERVERHOST_IP/distribution/api/v1/release_bundle" -T createbundle.json
```
3. Sign RB through API
```
   curl -u $MYUSER:$MYPASSWORD -H "Accept: application/json" -H "Content-Type: application/json" -H "X-GPG-PASSPHRASE: $PASSPHRASE" -X POST "$PROTOCOL://$MYSERVERHOST_IP/distribution/api/v1/release_bundle/lenovo-sample-rb/1.0/sign"
```
4. Distribute
```
   curl -u $MYUSER:$MYPASSWORD -H "Content-Type: application/json" -X POST "$PROTOCOL://$MYSERVERHOST_IP/distribution/api/v1/distribution/lenovo-sample-rb/1.0" -T distribute.json
```
=================
Another example from https://jira.jfrog.org/browse/XRAY-9855

export VISION_TOKEN=""
export JF_ENTPLUS_USER=""
export JF_ENTPLUS_TOKEN=""
export JF_RELEASES_USER=""
export JF_RELEASES_TOKEN=""
export OUTPUT_FILENAME="xray_exposures.tar.zst"
export JF_ENTPLUS_SOURCE_REPO="jfsexp-xray-exposures-dev"
export JF_RELEASES_TARGET_REPO="jfsexp-xray-exposures-dev"
export JF_ENTPLUS_BUNDLE_VERSION="1.1"

# Get from Vision
curl -X GET -H "Authorization: Token ${VISION_TOKEN}" http://127.0.0.1:8000/v1/xray/exposures/ --output ${OUTPUT_FILENAME}

# Upload to repo21
curl -X PUT -u "${JF_ENTPLUS_USER}:${JF_ENTPLUS_TOKEN}" "https://entplus.jfrog.io/artifactory/${JF_ENTPLUS_SOURCE_REPO}/${OUTPUT_FILENAME}" --data-binary @${OUTPUT_FILENAME}

# Create Release Bundle
curl -X POST -u "${JF_ENTPLUS_USER}:${JF_ENTPLUS_TOKEN}" "https://entplus.jfrog.io/distribution/api/v1/release_bundle" -H "Content-Type: application/json" -d "{\"sign_immediately\": true, \"dry_run\": false, \"name\": \"${JF_ENTPLUS_SOURCE_REPO}\", \"version\": \"${JF_ENTPLUS_BUNDLE_VERSION}\", \"spec\": {\"queries\": [{\"aql\": \"items.find({{ \\\"repo\\\": \\\"${JF_RELEASES_TARGET_REPO}\\\", \\\"name\\\": \\\"${OUTPUT_FILENAME}\\\" }})\", \"query_name\": \"package-query\"}],\"source_artifactory_id\": \"\"}}"

# Distribute release bundle
curl -X POST -u "${JF_ENTPLUS_USER}:${JF_ENTPLUS_TOKEN}" "https://entplus.jfrog.io/distribution/api/v1/distribution/jfrog-exposures/${RELEASE_BUNDLE_VERSION}" -H "Content-Type: application/json" -d "{\"distribution_rules\": [{\"site_name\": \"releases.jfrog.io\"}]}"

# Get SignedURL from releases
echo $(curl -X POST -H "X-JFrog-Art-Api:${JF_RELEASES_TOKEN}" "https://releases.jfrog.io/artifactory/api/signed/url" -H "Content-Type: application/json" -d "{ \"repo_path\": \"/jfrog-exposures/${OUTPUT_FILENAME}\", \"valid_for_secs\":31536000}")

---
## Check Distribution Service Healthcheck

You can use the Distribution Service APIs listed under https://jfrog.com/help/r/jfrog-rest-apis/general for the Service Status as below:

Note: Instead of psazuse.jfrog.io use your artifactory base url in below APIs.

curl -H "Authorization: Bearer $MYTOKEN"  "https://psazuse.jfrog.io/distribution/api/v1/system/ping"

Output:
{"message":"ok","status_code":200}

curl -H "Authorization: Bearer $MYTOKEN"  "https://psazuse.jfrog.io/distribution/api/v1/system/info"

Output:
{"status":"STABLE","version":"2.24.0","service_id":"jfds@01hq5ham68b9hs1hk5mkeg10nb"}%

curl -H "Authorization: Bearer $MYTOKEN"  "https://psazuse.jfrog.io/distribution/api/v1/system/settings"

Output:
{"call_home_enabled":true}

---
Get public key using:
```text
ARTIFACTORY_BASE_URL=soleng.jfrog.io

curl -u user:password -X GET "https://$ARTIFACTORY_BASE_URL/distribution/api/v1/keys/gpg"

or

curl -X GET -H "Authorization: Bearer $MYTOKEN" "https://$ARTIFACTORY_BASE_URL/distribution/api/v1/keys/gpg"
```

---
Get the release bundles on the Edge (target location) i.e , the distributed ones , just using the /artifactory
```text
jf rt curl -XGET api/release/bundles --server-id=solengedge
```
Output:
```text
{
  "bundles" : {
    "droBundleApp" : [ {
      "version" : "1.152",
      "created" : "2023-05-24T09:40:24.607Z",
      "status" : "COMPLETE",
      "keep" : false
    }, {
      "version" : "1.102",
      "created" : "2022-12-15T15:18:24.379Z",
      "status" : "COMPLETE",
      "keep" : false
    }
     ],
     "test_Nishu" : [ {
      "version" : "1.0",
      "created" : "2023-01-20T09:38:15.870Z",
      "status" : "COMPLETE",
      "keep" : false
    } ]
    }
}
```
Then  get a specific  release bundle version details ,  the distributed one , on the Edge (target location)
GET artifactory/api/release/bundles/{bundle-name}/{bundle-version}
```text
jf rt curl -XGET api/release/bundles/droBundleApp/1.152 --server-id=solengedge
```
Output:
```text
{
  "name": "droBundleApp",
  "version": "1.152",
  "description": "Docker images and doc bundle",
  "release_notes": {
    "content": "## Demo Bundle Description\n  * Sample bundle of app and pdf\n  * Triggered by adding a given property\n",
    "syntax": "markdown"
  },
  "created": "2023-05-10T14:05:56.651+0000",
  "artifacts": [
    {
      "repo_path": "dro-misc-assets-local/MultiSite.pdf",
      "checksum": "dad20eaa12cb86b41f6e35e23e07ddca4ed854533245defa8dcf1e4e2cead024",
      "props": [
        {
          "key": "drobundle.version",
          "values": [
            "1.152"
          ]
        },
        {
          "key": "drobundle.status",
          "values": [
            "ok"
          ]
        },
        {
          "key": "not.a.trigger",
          "values": [
            "foobar"
          ]
        }
      ]
    }
   ]
}
```
---

Get the release bundles on the Distribution Service (source location), those which can be distributed :


GET distribution/api/v1/release_bundle/:name/:version  - is for the 

```text
export ARTIFACTORY_BASE_URL=soleng.jfrog.io
curl -X GET -H "Authorization: Bearer $MYTOKEN" "https://$ARTIFACTORY_BASE_URL/distribution/api/v1/release_bundle"
```
Output:
```text
[
  {
    "name": "Gradle-Dist",
    "version": "1",
    "storing_repository": "release-bundles",
    "description": "Distribute Gradle Build",
    "created": "2020-07-01T16:40:40.976+0000",
    "created_by": "admin",
    "artifacts": [],
    "artifacts_size": 45908890,
    "archived": false,
    "state": "OPEN",
    "xray_triggering_status": "TRIGGERED",
    "spec": {}
  },
  {
    "name": "Gradle-Dist",
    "version": "1.1.2",
    "storing_repository": "release-bundles",
    "description": "Distribute Gradle Build",
    "created": "2020-10-14T10:00:44.601+0000",
    "created_by": "admin",
    "artifacts": [],
    "artifacts_size": 253720654,
    "archived": false,
    "state": "OPEN",
    "xray_triggering_status": "TRIGGERED",
    "spec": {}
  }
]
```
---

Get the details ofa specific version
```text
curl -X GET -H "Authorization: Bearer $MYTOKEN" "https://$ARTIFACTORY_BASE_URL/distribution/api/v1/release_bundle/Gradle-Dist/1"
```
Output:
```text
{
  "name": "Gradle-Dist",
  "version": "1",
  "storing_repository": "release-bundles",
  "description": "Distribute Gradle Build",
  "release_notes": {
    "content": "Test",
    "syntax": "markdown"
  },
  "created": "2020-07-01T16:40:40.976+0000",
  "created_by": "admin",
  "artifacts": [
    {
      "checksum": "dfb2d1594bcfcaf47cf881f85b5f6e329cf3b61782d6d697107c7f2debd2d869",
      "props": [
        {
          "key": "vcs.revision",
          "values": [
            "00a62ab3f52e7e9cfb0a8955a425e61aa3101f15"
          ]
        },
        {
          "key": "build.timestamp",
          "values": [
            "1593616888694"
          ]
        },
        {
          "key": "build.number",
          "values": [
            "25"
          ]
        },
        {
          "key": "build.name",
          "values": [
            "step-1-create-gradle-app-decl"
          ]
        },
                {
          "key": "vcs.url",
          "values": [
            "https:/github.com/jfrog/SolEngDemo.git"
          ]
        }
      ],
      "sourceRepoPath": "release-bundles/Gradle-Dist/1/gradle-release-local-decl/com/jfrog/frogsws/ivy-0.2.0-25.xml",
      "targetRepoPath": "gradle-release-local-decl/com/jfrog/frogsws/ivy-0.2.0-25.xml"
    }
     ],
  "artifacts_size": 45908890,
  "archived": false,
  "state": "READY_FOR_DISTRIBUTION",
  "xray_triggering_status": "TRIGGERED",
  "spec": {
    "queries": [
      {
        "aql": "items.find({\"$and\":[{\"$or\":[{\"repo\":{\"$eq\":\"gradle-release-local-decl\"}}]}]}).include(\"sha256\",\"updated\",\"modified_by\",\"created\",\"id\",\"original_md5\",\"depth\",\"actual_sha1\",\"property.value\",\"modified\",\"property.key\",\"actual_md5\",\"created_by\",\"type\",\"name\",\"repo\",\"original_sha1\",\"size\",\"path\")",
        "release_bundle_query_fields": {
          "repositories": [
            "gradle-release-local-decl"
          ],
          "included_artifacts_patterns": [],
          "excluded_artifacts_patterns": [],
          "search_properties_logical_operator": "$or",
          "included_logical_operator": "$or"
        },
        "query_name": "Gradle-Dist",
        "mappings": [],
        "added_props": [],
        "exclude_props_patterns": [],
        "query_type": "SIMPLE"
      }
    ]
  }
}
```
---

api/v1/release_bundle/{{name}}/{{version}}/{{id}}  is for RBv1 only.
for RBv2:
api/v2/lifecycle/distribution/trackers/{release_bundle_name}/{release_bundle_version} will give you all the distributions of the bundle

---
Customer thinks their Distribution GPG key usied to sign the Release bundle (RBv1) that was already distributed may 
have expired.
In that case
a) how to find out which GPG key was used to sign and distribute the RBv1 to the edge in their SH instance ?
b) What should they do if their GPG key has expired ?

You can use the [Get Release Bundle v1 Version](https://jfrog.com/help/r/jfrog-rest-apis/get-release-bundle-v1-version) API
GET api/v1/release_bundle/:name/:version[?format=json | jws
```text
export ARTIFACTORY_BASE_URL=soleng.jfrog.io
curl -X GET -H "Authorization: Bearer $MYTOKEN" "https://$ARTIFACTORY_BASE_URL/distribution/api/v1/release_bundle/droBundleApp/1.152?format=jws"

```

Output:
```text
{
  "header": "eyJraWQiOiJiYjlmNDMiLCJhbGciOiJSUzI1NiJ9",
  "payload": "eyJuYW..."
  "signature": "Pb2UptOTw55..."
}
```
If you base64 decode "eyJraWQiOiJiYjlmNDMiLCJhbGciOiJSUzI1NiJ9" you will get
{"kid":"bb9f43","alg":"RS256"}
From this you can find the "Key ID" that matches "bb9f43" in the output of https://soleng.jfrog.io/ui/admin/artifactory/security/keys_management/public_keys/ 
which internally invokes the UI API  https://soleng.jfrog.io/ui/api/v1/ui/security/trustedKeysRequest

The key details is :
```text
[
{
"kid": "bb9f43",
"alias": "soleng-gpg",
"fingerprint": "22:3b:d3:7a:8b:de:73:ae:8c:f3:9e:b3:95:67:07:22:b9:c7:70:f6",
"issued": 1591040893000,
"issuedBy": "soleng <soleng+noreply@jfrog.com>",
"expiry": 0
}
]
```

