#!/bin/bash

# Goto project dir
cd "${1}"

git clone "${2}" $3
if [[ $? -eq 0 ]]; then
	echo -e "\033[0;36mGit clone success\033[0m";

	cd $3

	if [ -f composer.json ]; then
		echo -e "\033[0;36mUpdating Composer\033[0m"
		# Check composer version
		composerversion=$(composer --version)

		if [[ "$composerversion" =~ "/usr/bin/composer self-update" ]]
			then
			sudo /usr/bin/composer self-update
		fi
		composer update
	fi

	# Update bower
	bower_files="$(find . -name 'bower.json')"

	if [ "$bower_files" != "" ]; then

		IFS=' ' read -a bower_files_array <<< "$bower_files"

		for bower_file in "${bower_files_array[@]}"
		do
			echo -e "\033[0;36mUpdating Bower in \033[1;36m${bower_file//bower.json/}\033[0m"
			cd "${bower_file//bower.json/}"
			bower update
			cd "${1}/${3}"
		done

	fi
else
	echo -e "Something went wrong";
fi
