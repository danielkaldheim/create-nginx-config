#!/bin/bash

source ~/.bash_ncreate_config

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
mkdir -v logs

if [ ! -z "$4" ]; then

	$NCREATE_SCRIPT_PATH/gitPublish.sh "${1}/${2}" $4 public_html
	cd public_html

	if [ ! -f nginx.conf ]; then
		# Add a blank nginx config
		touch nginx.conf
	fi

else
	mkdir -v public_html
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

fi

if [ $POST_RECEIVE_SCRIPT_PATH != "" ]; then
	POST_RECEIVE_SCRIPT_PATH_ROOT=`dirname ${POST_RECEIVE_SCRIPT_PATH}`
	GIT_TOPLEVEL_PATH="$(git rev-parse --show-toplevel)"
	if [ -f "${POST_RECEIVE_SCRIPT_PATH_ROOT}/post-merge" ]; then
		ln -s "${POST_RECEIVE_SCRIPT_PATH_ROOT}/post-merge" "${GIT_TOPLEVEL_PATH}/.git/hooks/post-merge"
	fi
fi
