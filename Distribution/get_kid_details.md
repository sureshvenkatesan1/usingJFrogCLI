
# get_kid_details.sh

This script retrieves the details of a GPG key used to sign and distribute a specific release bundle in JFrog Artifactory.

## Usage

```sh
./get_kid_details.sh <MYTOKEN> <ARTIFACTORY_BASE_URL> <RELEASE_BUNDLE_NAME> <RELEASE_BUNDLE_VERSION>
```

## Parameters

- `MYTOKEN`: Your JFrog Artifactory API token.
- `ARTIFACTORY_BASE_URL`: The base URL of your JFrog Artifactory instance.
- `RELEASE_BUNDLE_NAME`: The name of the release bundle.
- `RELEASE_BUNDLE_VERSION`: The version of the release bundle.

## Example

```sh
./get_kid_details.sh my_api_token soleng.jfrog.io droBundleApp 1.152
```

## Description

1. The script checks if all required parameters are provided. If not, it prints the usage and exits.
2. It assigns the provided parameters to variables.
3. It makes a `curl` request to get the release bundle details in JWS format.
4. It extracts the `header` value from the response using `jq`.
5. It decodes the Base64 encoded header to get the JSON object.
6. It extracts the value of `kid` from the decoded header using `jq`.
7. It prints the extracted `kid` value for debugging purposes.
8. It makes a `curl` request to get the key details from the keys management API.
9. It prints the key details for debugging purposes.
10. It extracts the details for the specific `kid` using `jq`.
11. It prints the details for the specified `kid`.

## Dependencies

- `curl`
- `jq`
- `base64` (usually available by default on Unix-like systems)

Make sure these dependencies are installed and accessible in your system's `PATH`.

## Debugging

The script includes debugging statements that print the extracted `kid` value and the raw key details. Uncomment the last debugging statement to print the matched `kid` details if needed.

## Note

Replace the placeholder values with your actual JFrog Artifactory API token, base URL, release bundle name, and version when running the script.
