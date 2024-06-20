#!/bin/bash

# Usage function to display help
usage() {
  echo "Usage: $0 -u <url> -i <check_interval> -t <latency_threshold> -f <consecutive_failures>"
  exit 1
}

# Parse command-line arguments
while getopts "u:i:t:f:" opt; do
  case $opt in
    u) URL=$OPTARG ;;
    i) CHECK_INTERVAL=$OPTARG ;;
    t) ALERT_LATENCY_THRESHOLD=$OPTARG ;;
    f) ALERT_CONSECUTIVE_FAILURES=$OPTARG ;;
    *) usage ;;
  esac
done

# Check if all required arguments are provided
if [ -z "$URL" ] || [ -z "$CHECK_INTERVAL" ] || [ -z "$ALERT_LATENCY_THRESHOLD" ] || [ -z "$ALERT_CONSECUTIVE_FAILURES" ]; then
  usage
fi

# Enable debug mode
#set -x

# Trap to catch errors and exit
trap 'echo "An error occurred. Exiting..."; exit 1' ERR

consecutive_failures=0
consecutive_high_latency=0
script_start_time=$(date +%s)

send_alert() {
  local message=$1
  # Placeholder for alerting mechanism (e.g., send email, Slack message, etc.)
  echo "ALERT: $message"
}

check_readiness() {
  start_time=$(date +%s.%N)
  response=$(curl -s -o /dev/null -w "%{http_code}" $URL)
  end_time=$(date +%s.%N)
  latency=$(echo "$end_time - $start_time" | bc -l)

  if [ "$response" -eq 200 ]; then
    echo $latency
  else
    echo "fail"
  fi
}

while true; do
  latency=$(check_readiness)

  echo "Debug: Latency = $latency"

  if [ "$latency" != "fail" ]; then
    if (( $(echo "$latency > $ALERT_LATENCY_THRESHOLD" | bc -l) )); then
      consecutive_high_latency=$((consecutive_high_latency + 1))
      echo "Debug: Consecutive high latency = $consecutive_high_latency"
      if [ $consecutive_high_latency -ge $ALERT_CONSECUTIVE_FAILURES ]; then
        send_alert "Readiness check latency exceeded ${ALERT_LATENCY_THRESHOLD} seconds for ${ALERT_CONSECUTIVE_FAILURES} consecutive occurrences"
      fi
    else
      consecutive_high_latency=0
    fi
  else
    consecutive_high_latency=0
  fi

  if [ "$latency" == "fail" ]; then
    consecutive_failures=$((consecutive_failures + 1))
    echo "Debug: Consecutive failures = $consecutive_failures"
    if [ $((consecutive_failures * $CHECK_INTERVAL)) -ge 300 ]; then
      send_alert "System has been unresponsive for at least 5 minutes"
    fi
  else
    consecutive_failures=0
  fi

  sleep $CHECK_INTERVAL
done

# Disable debug mode
#set +x
