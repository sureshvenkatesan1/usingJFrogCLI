# SBOM Software Components Report Generator

This script generates an HTML report analyzing Software Bill of Materials (SBOM) components across multiple repositories in JFrog Artifactory. It provides insights into repositories and artifacts that have fewer components than a specified threshold.

## Features

- Processes multiple repositories in parallel
- Processes artifacts within each repository in parallel
- Generates a single HTML report with:
  - Interactive package type summary with visual bars
  - Repository-specific tables with component details
  - Clickable links to SBOM details in JFrog UI
  - Highlighted rows for artifacts below component threshold
- Supports multiple debug levels for troubleshooting
- Handles different package types (maven, npm, docker, etc.)
- Supports remote repositories by automatically using cache repositories

## Prerequisites

- Python 3.6+
- Required Python packages:
  ```bash
  pip install requests pandas tqdm
  ```
- JFrog Artifactory access token with appropriate permissions

## Usage
python sbom_sw_components_report_for_repos.py \
--base-url BASE_URL \
--token TOKEN \
--repositories REPO_LIST \
[--parallel-artifacts PARALLEL_ARTIFACTS] \
[--parallel-repos PARALLEL_REPOS] \
[--debug-level {0,1,2}] \
[--threshold THRESHOLD]

### Parameters

- `--base-url` (required): JFrog Artifactory base URL
  - Example: `https://your-instance.jfrog.io`

- `--token` (required): JFrog access token
  - Example: `$MYTOKEN` (from environment variable)

- `--repositories` (required): Semicolon-separated list of repository names
  - Example: `"repo1;repo2;repo3"`

- `--parallel-artifacts` (optional): Number of artifacts to process in parallel within each repository
  - Default: 3
  - Example: `--parallel-artifacts 5`

- `--parallel-repos` (optional): Number of repositories to process in parallel
  - Default: 3
  - Example: `--parallel-repos 2`

- `--debug-level` (optional): Level of debug information
  - Default: 0 (no debug)
  - Choices:
    - 0: No debug output
    - 1: Show curl commands for errors only
    - 2: Show all curl commands
  - Example: `--debug-level 2`

- `--threshold` (optional): Minimum number of components threshold
  - Default: 2
  - Example: `--threshold 100`

### Example Commands

1. Basic usage with defaults:
```bash
python sbom_sw_components_report_for_repos.py \
  --base-url "https://your-instance.jfrog.io" \
  --token $MYTOKEN \
  --repositories "repo1;repo2;repo3"
```

2. High parallelization with higher threshold:
```bash
python sbom_sw_components_report_for_repos.py \
  --base-url "https://your-instance.jfrog.io" \
  --token $MYTOKEN \
  --repositories "repo1;repo2;repo3;repo4" \
  --parallel-artifacts 5 \
  --parallel-repos 3 \
  --threshold 50
```

3. Debugging mode for troubleshooting:
```bash
python sbom_sw_components_report_for_repos.py \
  --base-url "https://your-instance.jfrog.io" \
  --token $MYTOKEN \
  --repositories "repo1;repo2" \
  --debug-level 2
```

4. Production run with many repositories:
```bash
python sbom_sw_components_report_for_repos.py \
  --base-url "https://your-instance.jfrog.io" \
  --token $MYTOKEN \
  --repositories "maven-local;npm-local;docker-local;generic-local" \
  --parallel-artifacts 10 \
  --parallel-repos 4 \
  --threshold 100
```

## Output

The script generates two files with matching timestamps:

1. HTML Report: `sbom_analysis_report_YYYYMMDD_HHMMSS.html`
   - Package type summary with visual bars
   - Repository sections with detailed tables
   - Highlighted rows for artifacts below threshold
   - Clickable links to JFrog UI

2. Log File: `sbom_report_YYYYMMDD_HHMMSS.log`
   - Processing progress
   - Error messages
   - Debug information (if enabled)
   - Curl commands (based on debug level)

## Debug Levels

1. Level 0 (default):
   - Basic progress information
   - Error messages

2. Level 1:
   - Everything from Level 0
   - Curl commands for failed requests
   - Curl commands for zero-component artifacts

3. Level 2:
   - Everything from Level 1
   - Curl commands for all API requests
   - Detailed repository information
   - Cache repository usage information

## Notes

- For remote repositories, the script automatically appends "-cache" to the repository name
- The HTML report is interactive with collapsible package type sections
- Progress bars show both repository and artifact processing status
- The report highlights artifacts with component counts below the threshold
- Package types are sorted by number of low-component artifacts



