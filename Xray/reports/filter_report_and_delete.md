
# Filter Report and Delete Script

This script filters reports based on specified criteria and deletes them. It utilizes the JFrog CLI to interact with JFrog Xray APIs.

## Usage

```bash
bash filter_report_and_delete.sh <status> <report_type> <end_time> <server-id> [dry_run]
```

- `<status>`: Status of the reports to filter (e.g., "completed").
- `<report_type>`: Type of the reports to filter (e.g., "vulnerability").
- `<end_time>`: End time threshold for filtering the reports (e.g., "2020-09-08T20:51:28Z").
- `<server-id>`: Server ID of the JFrog Xray instance.
- `[dry_run]`: Optional flag to perform a dry run. Set to "false" to execute deletions.

## Description

The script performs the following steps:

1. Checks if all required parameters are provided.
2. Parses the command-line arguments.
3. Fetches reports using the JFrog CLI and filters them based on the provided criteria.
4. Then, it prints total reports available, unique statuses and report types found in the reports.
5. Iterates over the filtered reports.
6. Deletes each filtered report, or prints the deletion command if the dry run flag is set.

## Requirements

- Bash shell
- JFrog CLI installed and configured

## Example

```bash
bash filter_report_and_delete.sh "completed" "vulnerability" "2020-09-08T20:51:28Z" "soleng" false
```

This command filters reports with status "completed", report type "vulnerability", and end time earlier than i.e before  "2020-09-08T20:51:28Z" on the JFrog Xray server with server ID "soleng", and executes deletions on the report matched by the filter.

