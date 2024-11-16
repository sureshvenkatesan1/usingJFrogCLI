#!/bin/bash

# Prompt for username and password
read -p "Enter your username: " username
read -sp "Enter your password: " password
echo

# Define the URL
url="https://my.artifactory.com/artifactory/enovia-Testing/examplemaven.zip"

# Download the file in parts
curl -r 0-10485759 -o part1 -O -L -u "$username:$password" "$url"
curl -r 10485760-300971519 -o part2 -O -L -u "$username:$password" "$url"

# Combine the parts into one file
cat part1 part2 > examplemaven.zip

# Clean up the parts
rm part1 part2

echo "Download and combination complete. The file is saved as examplemaven.zip"
