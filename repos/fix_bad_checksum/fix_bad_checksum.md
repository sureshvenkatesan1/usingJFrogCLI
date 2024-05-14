To determine if a given artifact has mismatching checksums? Or  a way to automatically fix the
checksum for an entire repo:
Get a list of artifacts with bad checksums using the [Bad Checksum Search API endpoint](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#ArtifactoryRESTAPI-BadChecksumSearch)
For each artifact in this list, execute the following Fix Checksum endpoint:
```
curl -u user:password -XPOST -H "Content-Type: application/json" <ART-URL>/artifactory/api/checksums/fix  -d @request.json
```
Where the request.json file has the following parameters:

```
{path: "<path to artifact>", repoKey: "<repo name>"}
```