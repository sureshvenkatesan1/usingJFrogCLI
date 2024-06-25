AQL to fetch the buildinfo from artifactory which have an environment variable JOB_NAME with value 
"step-3b-create-docker-multi-app" :

```text
jf rt curl -XPOST /api/search/aql -H 'Content-Type: text/plain' --server-id=soleng -d 'builds.find({
  "@buildInfo.env.JOB_NAME": {
    "$match": "step-3b-create-docker-multi-app"
  }
})'

```
Sample Output:
```text
{
"results" : [ {
  "build.created" : "2023-02-16T04:31:41.005Z",
  "build.created_by" : "jenkins",
  "build.name" : "step-3b-create-docker-multi-app",
  "build.number" : "139",
  "build.repo" : "artifactory-build-info",
  "build.started" : "2023-02-16T04:28:14.571Z",
  "build.url" : "http://jenkins-unified.soleng-us.jfrog.team/job/step-3b-create-docker-multi-app/139/"
},{
  "build.created" : "2023-02-16T04:38:25.556Z",
  "build.created_by" : "jenkins",
  "build.name" : "step-3b-create-docker-multi-app",
  "build.number" : "140",
  "build.repo" : "artifactory-build-info",
  "build.started" : "2023-02-16T04:34:27.526Z",
  "build.url" : "http://jenkins-unified.soleng-us.jfrog.team/job/step-3b-create-docker-multi-app/140/"
}
],
"range" : {
  "start_pos" : 0,
  "end_pos" 2: ,
  "total" : 2
}
}
```
More aql examples in [JFTD103-JFrog_Platform_Automation](https://github.com/jfrog/SwampUp2023/blob/main/JFTD103-JFrog_Platform_Automation/lab-4-AQL/README.md)

--- 

