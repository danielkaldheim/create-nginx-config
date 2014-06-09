#!/bin/bash

# Save script folder
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd)

# Goto hosts dir
cd "${1}"

# Check if project dir exists
# If not, create it
if [ ! -d "${2}" ]; then
	mkdir "${2}"
fi

# Enter project dir
cd "${2}"

# Init Git, create README.md and make first commit
git init
touch README.md
git add README.md
git commit -m "Initial commit."

# Add .gitignore
cp "$SCRIPT_DIR/assets/.gitignore" .
git add .gitignore
git commit -m "Add .gitignore."

# Add a blank nginx config
touch nginx.conf
