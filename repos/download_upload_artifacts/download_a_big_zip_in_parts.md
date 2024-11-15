The curl download via F5 fronting Artifactory fails after downloading 9-13 MB  of a 200+MB zip file , though the curl download of /artifactory/alm-it-tools-local/klamaven.zip successfully works when requested on Artifactory  port 8082



curl -k -uadmin https://my.artifactory.com/artifactory/alm-it-tools-local/examplemaven.zip -L -o examplemaven.zip -vvv



The failure appears to be a  disconnect from the F5 server:
~~~~~~~~
* Recv failure: Connection was reset
* schannel: recv returned CURLE_RECV_ERROR
* schannel: failed to decrypt data, need more data
  6  217M    6 13.6M    0     0   336k      0  0:11:01  0:00:41  0:10:20 1817k
* Closing connection
* schannel: shutting down SSL/TLS connection with my.artifactory.com port 443
* Send failure: Connection was reset
* schannel: failed to send close msg: Failed sending data to the peer (bytes written: -1)
curl: (56) Recv failure: Connection was reset
~~~~~~~~~~~~
We see same "Failed - Network error" when the zipfile is downloaded via browser browser , and the the resume download completes the download.

As a workaround 
