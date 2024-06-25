
# JFrog Artifactory AQL Queries

This repository contains AQL queries for searching items in the `Marvolo-LFS-local` repository based on different time-based criteria.

## Prerequisites

- JFrog CLI
- `jq` for parsing JSON output

## Queries

### 1. Find items downloaded before a specific time

This query finds items in the `Marvolo-LFS-local` repository that were downloaded more than 2 years ago.

#### Query

```bash
aql_url="api/search/aql"
repo="Marvolo-LFS-local"
olderthan="2y"
aql_info="items.find({
            \"repo\": \"$repo\",
            \"stat.downloaded\" : {\"\$before\":\"$olderthan\"}
}).include(\"path\")"

jf rt curl -s -XPOST "${aql_url}" -H "content-type: text/plain" --data "$aql_info" --server-id=dishtechnology | jq -r '.results[] | .path'
```

### 2. Find items downloaded within the last specific time

This query finds items in the `Marvolo-LFS-local` repository that were downloaded within the last 3 years.

#### Query

```bash
aql_url="api/search/aql"
repo="Marvolo-LFS-local"
timeperiod="3y"
aql_info="items.find({
            \"repo\": \"$repo\",
            \"stat.downloaded\" : {\"\$last\":\"$timeperiod\"}
}).include(\"path\")"

jf rt curl -s -XPOST "${aql_url}" -H "content-type: text/plain" --data "$aql_info" --server-id=dishtechnology | jq -r '.results[] | .path'
```

### 3. Find items that were never downloaded

This query finds items in the `Marvolo-LFS-local` repository that have never been downloaded.

#### Query

```bash
aql_url="api/search/aql"
repo="Marvolo-LFS-local"
olderthan="3y"
aql_info="items.find({
            \"repo\": \"$repo\",
            \"stat.downloaded\" : {\"\$eq\":null}
}).include(\"path\")"

jf rt curl -s -XPOST "${aql_url}" -H "content-type: text/plain" --data "$aql_info" --server-id=dishtechnology | jq -r '.results[] | .path'
```

## Usage

1. Replace the placeholders (`aql_url`, `repo`, `olderthan`, and `server-id`) with your specific values.
2. Run the commands in your terminal.

## Notes

- The AQL queries use relative time operators to filter items based on their download statistics.
- The `jq` command is used to parse and extract the `path` from the query results.

For more details on relative time operators in AQL, refer to the [Relative Time Operators in AQL](https://jfrog.com/help/r/jfrog-artifactory-documentation/relative-time-operators-in-aql).
```

 Adjust the placeholders and content as necessary for your specific needs.