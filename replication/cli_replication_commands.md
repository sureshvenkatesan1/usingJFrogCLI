List all replications in a repo:

```
jf rt curl  -X GET "/api/replications" |  jq 'map(select(.cronExp != ""))' |  jq  '.[]| {test: (.repoKey + " " + ."replicationType" + " "  + .cronExp)}' | jq -r '.test'
```
Ref :
[jq - how to output document if a value is not null?](https://stackoverflow.com/questions/49105880/jq-how-to-output-document-if-a-value-is-not-null)

List only PULL replications which have cron schedule::
```
jf rt curl  -X GET "/api/replications" |  jq 'map(select(.cronExp != ""))' |  jq  '.[]| {test: (.repoKey + " " + .
"replicationType" + " "  + .cronExp)}' | jq -r '.test' | grep -i pull
```

List only PUSH replications which have cron schedule:

```
jf rt curl  -X GET "/api/replications" |  jq 'map(select(.cronExp != ""))' |  jq  '.[]| {test: (.repoKey + " " + ."replicationType" + " "  + .cronExp)}' | jq -r '.test' | grep -i push
```
Note: To filter based on equals i.e "[Select objects based on value of variable in object using jq](https://stackoverflow.com/questions/18592173/select-objects-based-on-value-of-variable-in-object-using-jq)" 
```text
$ jq '.[] | select(.location=="Stockholm")' json
```