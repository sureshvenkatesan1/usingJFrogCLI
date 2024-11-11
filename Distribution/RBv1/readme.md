## [The Distribution RBv1 Flow](https://jfrog.com/help/r/jfrog-distribution-documentation/the-distribution-flow) 

The general flow of creating a release bundle (RBv1)  is as follows:
- [Create a circle of trust](https://jfrog.com/help/r/jfrog-platform-administration-documentation/how-to-establish-a-circle-of-trust) between your source and edge nodes as mentioned in [JFrog Artifactory Edge](https://jfrog.com/help/r/get-started-with-the-jfrog-platform/jfrog-artifactory-edge)  just in  case you want to do Access Federation as well to the Edge. If you do not plan to do Access Federation to Edge then just Register  the Edge to the JPD using [Binding Tokens](https://jfrog.com/help/r/jfrog-platform-administration-documentation/binding-tokens) .  

- [Add JPD on Platform Deployment](https://jfrog.com/help/r/jfrog-platform-administration-documentation/managing-platform-deployments)
- [Generate GPG Keys](https://jfrog.com/help/r/jfrog-distribution-documentation/generate-gpg-keys) ( also see [GPG Signing](https://jfrog.com/help/r/jfrog-distribution-documentation/gpg-signing) )

Create a gpg.json like below:
```
{
 "alias":  "your-alias", 

  "public_key":  "-----BEGIN PGP PUBLIC KEY BLOCK-----
                  ....
                  -----END PGP PUBLIC KEY BLOCK-----",
  "private_key": "-----BEGIN PGP PRIVATE KEY BLOCK-----
                  ....
                  -----END PGP PRIVATE KEY BLOCK-----"
}
```

You can use [generate_gpg_key.sh](generate_gpg_key.sh) as mentioned in [generate_gpg_key.md](generate_gpg_key.md)

```
mkdir -p /tmp/test/

bash ./generate_gpg_key.sh "jfrog_distribution_key" "jfrog_distribution_key" "jfrog_distribution_key@jfrog.com" 2048 0 /tmp/gpg /tmp/test/thekey1.json

```

- [Upload GPG Signing Keys](https://jfrog.com/help/r/jfrog-rest-apis/upload-and-propagate-gpg-signing-keys-for-distribution) (can also be done from the UI) as  mentioned in KB [DISTRIBUTION: How to resolve Failed to set the PGP key during GPG keys upload](https://jfrog.com/help/r/distribution-how-to-resolve-failed-to-set-the-pgp-key-during-gpg-keys-upload)
``` 
curl -u $MYUSER:$MYPASSWORD  -H "Accept: application/json" -H "Content-Type: application/json" -X POST "localhost:8082/distribution/api/v1/keys/gpg" -T gpg.json

or

curl -u $MYUSER:$MYPASSWORD  -H "Accept: application/json" -H "Content-Type: application/json" -X POST "https://examplepsazuse.jfrog.io/distribution/api/v1/keys/gpg" -T /tmp/test/thekey1.json

```
The key gets propagated to the Mothership and all JPDs and Edges:
```
{
  "report": {
    "status": "SUCCESS",
    "details": [
      {
        "jpd_id": "JPD-1",
        "name": "examplepsazuse",
        "key_alias": "gpg-1726700297282",
        "status": "SUCCESS"
      },
      {
        "jpd_id": "JPD-3",
        "name": "examplepsemea",
        "key_alias": "gpg-1726700297282",
        "status": "SUCCESS"
      },
      {
        "jpd_id": "JPD-4",
        "name": "examplesoleng",
        "key_alias": "gpg-1726700297282",
        "status": "SUCCESS"
      },
      {
        "jpd_id": "JPD-2",
        "name": "exaplepsazeuwedge",
        "key_alias": "gpg-1726700297282",
        "status": "SUCCESS"
      }
    ]
  }
}
```
- Propagate GPG signing keys to any new  distribution edges you register
```
curl localhost:8082/distribution/api/v1/keys/gpg/propagate -u $MYUSER:$MYPASSWORD -XPOST
```
- Create a distribution bundle, sign it, and release it as explained in [publish_RBV1_bundle_and_distribute_to_edge_in_CI_pipeline.md](publish_RBV1_bundle_and_distribute_to_edge_in_CI_pipeline.md)

- ALso review [useful_distribution_RBv1_usecases.md](useful_distribution_RBv1_usecases.md)
---

All APIs for Distribution RBv1 are in https://jfrog.com/help/r/jfrog-rest-apis/release-bundles-v1

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
---

