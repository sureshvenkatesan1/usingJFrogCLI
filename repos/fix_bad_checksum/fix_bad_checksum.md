
To verify and address mismatched checksums for artifacts, follow these steps:

1. Identify artifacts with incorrect checksums using the [Bad Checksum Search](https://jfrog.com/help/r/jfrog-rest-apis/bad-checksum-search) API endpoint. This endpoint will provide a list of artifacts that have mismatching checksums.

2. For each artifact identified, use the `Fix Checksum` endpoint to correct the checksums:
   ```bash
   curl -u user:password -XPOST -H "Content-Type: application/json" <ART-URL>/artifactory/api/checksums/fix -d @request.json
   ```
   In this command, replace `<ART-URL>` with your Artifactory URL.

Note: The [find_and_fix_badchecksum.sh](find_and_fix_badchecksum.sh) prepares the `request.json` file with the necessary  parameters for each artifact as follows:
   ```json
   {
     "path": "<path to artifact>",
     "repoKey": "<repo name>"
   }
   ```
Update `<path to artifact>` and `<repo name>` with the appropriate path and repository key for each artifact identified

These steps will help you systematically resolve any checksum discrepancies in your repository.

Note: If you want tom update the database table directly then review the SQls in KB "[How to identify and fix all artifacts with missing client checksums](https://jfrog.com/help/r/artifactory-how-to-identify-and-fix-all-artifacts-with-missing-client-checksums)"