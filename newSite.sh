#!/bin/bash

# Save script folder
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd)

# Goto hosts dir
cd "${1}"

# Check if project dir exists
# If not, create it
if [ ! -d "${2}" ]; then
	mkdir -v "${2}"
fi

# Enter project dir
cd "${2}"
mkdir -v public_html
mkdir -v logs
cd public_html

# Init Git, create README.md and make first commit
git init
touch README.md
echo "# ${2}" >> README.md
echo "Database name: ${3}" >> README.md

git add README.md
git commit -m "Initial commit."

# Add .gitignore
cp -v "$SCRIPT_DIR/assets/.gitignore" .
git add .gitignore
git commit -m "Add .gitignore."

# Add a blank nginx config
touch nginx.conf
