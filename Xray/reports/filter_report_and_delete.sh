#!/bin/bash
# Usage: bash Xray/reports/filter_report_and_delete.sh "completed" "vulnerability" "2020-09-08T20:51:28Z" "soleng" [dry_run]
# Check if all required parameters are provided
if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <status> <report_type> <end_time> <server-id> [dry_run]"
    exit 1
fi

status="$1"
report_type="$2"
end_time="$3"
server_id="$4"

# Check if dry run flag is provided
dry_run=true
if [ "$#" -eq 5 ] && [ "$5" == "false" ]; then
    dry_run=false
fi

# Fetch reports and filter using jq
reports_info=$(jf xr curl -s -XPOST "/api/v1/reports?direction=asc&page_num=1&num_of_rows=10&order_by=status" --server-id="$server_id")
total_reports=$(echo "$reports_info" | jq -r '.total_reports')

# Fetch unique statuses and report types
unique_data=$(jf xr curl -s -XPOST "/api/v1/reports?direction=asc&page_num=1&num_of_rows=$total_reports&order_by=status" --server-id="$server_id" | \
    jq -r '.reports[] | {status: .status, report_type: .report_type}' )

# Extract unique statuses and report types
unique_statuses=$(echo "$unique_data" | jq -r '.status' | sort -u)
unique_report_types=$(echo "$unique_data" | jq -r '.report_type' | sort -u)

# Print unique statuses and report types
echo "Total reports:"
echo "$total_reports"
echo
echo "Unique Statuses:"
echo "$unique_statuses"
echo
echo "Unique Report Types:"
echo "$unique_report_types"
echo

# Fetch reports with updated num_of_rows value
reports=$(jf xr curl -s -XPOST "/api/v1/reports?direction=asc&page_num=1&num_of_rows=$total_reports&order_by=status" --server-id="$server_id" | \
    jq --arg status "$status" --arg report_type "$report_type" --arg end_time "$end_time" \
    '[.reports[] | select(.status == $status and .report_type == $report_type and .end_time < $end_time)]')

# Loop through filtered reports and delete them (or print if dry run)
echo "$reports" | jq -c '.[]' | while IFS= read -r line; do
#    echo "line is"
#    echo "$line"
    id=$(echo "$line" | jq -r '.id')
    if [ "$dry_run" == true ]; then
        echo "Dry run: jf xr curl -s -XDELETE \"/api/v1/reports/$id\" --server-id=\"$server_id\""
    else
        jf xr curl -s -XDELETE "/api/v1/reports/$id" --server-id="$server_id"
    fi
done
