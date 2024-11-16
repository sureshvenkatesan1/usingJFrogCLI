#### Issue Summary
When attempting to download a large file (e.g., a 200+ MB ZIP file) from Artifactory via a URL fronted by an F5 load balancer, the `curl` download fails after downloading around 9-13 MB. This failure does not occur when accessing Artifactory directly on port 8082.

#### Example of the Failed Download Command
```bash
curl -k -u admin https://my.artifactory.com/artifactory/alm-it-tools-local/examplemaven.zip -L -o examplemaven.zip -vvv
```

#### Error Message
During the download, the following error is encountered:
```plaintext
* Recv failure: Connection was reset
* schannel: recv returned CURLE_RECV_ERROR
* schannel: failed to decrypt data, need more data
6 217M    6 13.6M    0     0   336k      0  0:11:01  0:00:41  0:10:20 1817k
* Closing connection
* schannel: shutting down SSL/TLS connection with my.artifactory.com port 443
* Send failure: Connection was reset
* schannel: failed to send close msg: Failed sending data to the peer (bytes written: -1)
curl: (56) Recv failure: Connection was reset
```

This error indicates that the connection was reset by the F5 server, causing the download to fail. The same issue occurs when downloading via a browser, showing a "Failed - Network error," but the browser's resume download feature allows for a successful completion.

Simialrly downloading using the curl  "-C"  resume option ( with the partial size 14328632 bytes that was already downloaded in the furst curl download attempt) also downloads the complete file:
```
curl -k -u admin -L -o examplemaven.zip -C 14328632 "https://my.artifactory.com/artifactory/alm-it-tools-local/examplemaven.zip" -v
```

#### Workaround Script
To bypass this connection reset issue, we created a script to download the file in smaller parts and then combine them. This approach avoids downloading the entire file in one go, reducing the likelihood of a disconnection from the F5 server.

#### Workaround Script Explanation

The script `download_in_parts.sh` performs the following steps:

1. **Prompts for Username and Password**:
   - The script prompts the user to enter their Artifactory credentials, which are required to authenticate the download.

2. **Define the URL to download**:
   - Set the URL for the file to be downloaded  `https://my.artifactory.com/artifactory/alm-it-tools-local/examplemaven.zip`.

3. **Downloads the File in Parts**:
   - The file is divided into two parts by specifying byte ranges for each part in the `curl` command. 
   - The first `curl` command downloads bytes 0 to 10,485,759 (10 MB) and saves them as `part1`.
   - The second `curl` command downloads from byte 10,485,760 to the end of the file and saves it as `part2`.
   
   ```bash
   curl -r 0-10485759 -o part1 -O -L -u "$username:$password" "$url"
   curl -r 10485760-300971519 -o part2 -O -L -u "$username:$password" "$url"
   ```

4. **Combines the Parts**:
   - After downloading, the `cat` command concatenates `part1` and `part2` into a single file named `examplemaven.zip`.

   ```bash
   cat part1 part2 > examplemaven.zip
   ```

5. **Cleans Up the Parts**:
   - The script removes the temporary part files (`part1` and `part2`) to save disk space.

   ```bash
   rm part1 part2
   ```

6. **Displays a Completion Message**:
   - Finally, it outputs a message indicating the download and combination are complete.

### Script Usage
To use this script, run it in a terminal and provide your Artifactory credentials when prompted.

```bash
./download_in_parts.sh
```

### Benefits of This Workaround
This script mitigates the F5 disconnect issue by breaking the download into smaller parts, each of which is less likely to trigger a connection reset. This approach ensures the complete file is downloaded without needing to rely on the browser's resume feature or encountering frequent disconnects.