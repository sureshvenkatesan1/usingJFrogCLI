How to xray index/scan each artifact in a release bundle ?
USed in [#211812](https://groups.google.com/a/jfrog.com/g/support-followup/c/ZsrLiseY8tg/m/Nhi7-8UBAQAJ) 
troubleshooting to identify [RTFACT-27288](https://www.jfrog.com/jira/browse/RTFACT-27288)
```bash
#!/bin/bash
curl -u user:password1 -X GET "https://source.artifactory/distribution/api/v1/release_bundle/<insert bundle name here>/LATEST?format=json" | jq -r '.artifacts[] | .targetRepoPath' > files-bundle.txt
while read -r line; do
curl https://destination.artifactory/xray/api/v2/index -u user:password2 -XPOST -d '{"repo_path":"'"$line"'"}' -H "content-type: application/json"
done < files-bundle.txt
rm files-bundle.txt
```

---
