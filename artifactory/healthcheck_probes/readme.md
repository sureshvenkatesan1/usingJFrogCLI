
# Artifactory Readiness Probe Script

This script, `rt_readiness_probe.sh`, monitors the readiness of a JFrog Artifactory system by periodically checking its readiness endpoint. It sends an alert if the system fails to respond or if the response time exceeds a specified threshold for a consecutive number of occurrences.

## Usage

```bash
./rt_readiness_probe.sh -u <url> -i <check_interval> -t <latency_threshold> -f <consecutive_failures>
```

### Parameters

- `-u <url>`: The URL of the Artifactory readiness endpoint.
- `-i <check_interval>`: Interval between checks in seconds.
- `-t <latency_threshold>`: Latency threshold in seconds.
- `-f <consecutive_failures>`: Number of consecutive failures to trigger an alert.

### Example

```bash
./rt_readiness_probe.sh -u "https://example.jfrog.io/artifactory/api/v1/system/readiness" -i 2 -t 0.1 -f 2
```

## Functionality

1. **Parse Command-Line Arguments**: The script takes several arguments to configure the URL, check interval, latency threshold, and number of consecutive failures.

2. **Check Readiness**: The script periodically sends a GET request to the specified readiness endpoint. It measures the time taken for the request to complete.

3. **Alerting Mechanism**:
   - If the readiness check fails or the response latency exceeds the threshold for a consecutive number of occurrences, the script triggers an alert.
   - If the system remains unresponsive for a specified duration (e.g., 5 minutes), it triggers another alert.

### Explanation of Conditions

- **Latency Check**:
   - If the latency of a successful readiness check exceeds the `latency_threshold`, it increments the `consecutive_high_latency` counter.
   - If the `consecutive_high_latency` counter exceeds the `consecutive_failures` threshold, an alert is triggered.

- **Failure Check**:
   - If the readiness check fails, it increments the `consecutive_failures` counter.
   - If the `consecutive_failures` counter multiplied by the `check_interval` exceeds 300 seconds (5 minutes), an alert is triggered.

### Debugging

- The script includes debug statements to print the latency and consecutive failure counts.
- Debug mode can be enabled by uncommenting `set -x` and `set +x` lines.

## Notes

- **Alerting Mechanism**: The `send_alert` function is a placeholder. Customize it to integrate with your alerting system, such as sending an email or a Slack message.
- **Infinite Loop**: The script runs indefinitely, periodically checking the system readiness and responding to conditions as configured.

This script is useful for monitoring the health and responsiveness of a JFrog Artifactory instance, ensuring it remains available and performant.