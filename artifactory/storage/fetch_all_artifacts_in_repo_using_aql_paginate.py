import argparse
import subprocess
import json
import csv

def run_aql_query(server_id, aql_query):
    """
    Run the AQL query using JFrog CLI and return the results as a JSON object.
    """
    jfrog_command = [
        'jf', 'rt', 'curl', '-s', '-XPOST', '/api/search/aql',
        '-H', 'Content-Type: text/plain',
        '-d', aql_query,
        '--server-id', server_id
    ]

    # Print the exact command being executed
    print("Executing command:", " ".join(jfrog_command))

    result = subprocess.run(jfrog_command, capture_output=True, text=True)

    if result.returncode != 0:
        print(f"Failed to execute AQL query: {result.stderr}")
        return None

    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        print("Error: Failed to parse JSON response.")
        print("Raw output:", result.stdout)
        return None

def fetch_and_save_artifacts(server_id, repo_name, items_per_page, output_file):
    last_name = ""
    first_page = True

    with open(output_file, 'w', newline='') as csvfile:
        fieldnames = ['name', 'path', 'actual_md5', 'actual_sha1']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        # Write header only once
        writer.writeheader()

        while True:
            aql_query = (
                f'items.find({{"repo": "{repo_name}", "name": {{"$gt": "{last_name}"}}}})'
                '.include("name", "path", "actual_md5", "actual_sha1")'
                '.sort({"$asc": ["name"]})'
                f'.limit({items_per_page})'
            )

            result = run_aql_query(server_id, aql_query)

            if not result or not result.get('results'):
                break

            # Write the current page of artifacts to the CSV
            for artifact in result['results']:
                writer.writerow({
                    'name': artifact['name'],
                    'path': artifact['path'],
                    'actual_md5': artifact.get('actual_md5', ''),
                    'actual_sha1': artifact.get('actual_sha1', '')
                })

            # Update last_name for the next page of results
            last_name = result['results'][-1]['name']

def main():
    parser = argparse.ArgumentParser(description="Fetch artifacts from a JFrog Artifactory repository using AQL and save the output to a CSV file.")
    parser.add_argument('--server_id', required=True, help='The server ID configured in JFrog CLI.')
    parser.add_argument('--repo_name', required=True, help='The repository name to query.')
    parser.add_argument('--items_per_page', type=int, default=100, help='Number of items to fetch per page.')
    parser.add_argument('--output_file', required=True, help='The output CSV file.')

    args = parser.parse_args()

    fetch_and_save_artifacts(args.server_id, args.repo_name, args.items_per_page, args.output_file)

    print(f"Artifacts have been saved to {args.output_file}")

if __name__ == "__main__":
    main()
