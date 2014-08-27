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
	prev='';
	vendorPath="bower_components";
	find . -type f -iname "bower.json" -print0 | while IFS= read -r -d $'\0' bower_file_path; do
		bowerDir="${bower_file_path//bower.json/}";

		if [[ "${bowerDir}" != "${prev}${vendorPath}"* ]]; then
			echo -e "\033[0;36mUpdating Bower in \033[1;36m${bowerDir}\033[0m"

			cd $bowerDir;
			bower update
			cd "${1}/${3}"

			# Filter out bad dirs
			prev=$bowerDir;
			if [[ -f "${bowerDir}.bowerrc" ]]; then
				vendorPath=`cat "${bowerDir}.bowerrc" | python -c "import json,sys;obj=json.load(sys.stdin);print str(obj['directory'])"`
				if [[ "${vendorPath}" == *Traceback* ]]; then
					vendorPath="bower_components";
				fi
			fi
		fi

	done

else
	echo -e "Something went wrong";
fi
