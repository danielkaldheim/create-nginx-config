#!/bin/bash

source ~/.bash_ncreate_config

DOMAIN="$1.dev";

# check the domain is valid!
PATTERN="^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9\_]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$";
if [[ "$DOMAIN" =~ $PATTERN ]]; then
    DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
else
    echo "\033[0;31mInvalid domain name\033[0m"
    exit 1
fi

# Check folders
if [ -d "$GLOBAL_WWW_PATH/$DOMAIN" ]; then
	echo -e "\033[0;31mCan't create new site, path exists: \033[1;31m$GLOBAL_WWW_PATH/$DOMAIN\033[0m"
else

	while true
	do
		DATABASE_NAME=`echo $DOMAIN | tr '[\.]' '[_]'`
		echo -e "\033[0;32mWhat will the database be named? (press enter for \033[1;32m$DATABASE_NAME\033[0;32m) \033[0m"
		read DB
		if [[ ! -z $DB ]]; then
			DATABASE_NAME=$DB
		fi

		RESULT=`mysqlshow --user=$NCREATE_MYSQL_USER --password=$NCREATE_MYSQL_PASSWORD $DATABASE_NAME| grep -v Wildcard | grep -o $DATABASE_NAME`
		if [ "$RESULT" == "$DATABASE_NAME" ]; then
			echo -e "\033[0;31mCan't create new database, it exists: \033[1;31m$RESULT\033[0m"
			echo -e "\033[0;32mDo you want to create a new database? [Y/N] \033[0m"
			read yn
			case $yn
				in
					[yY])
						;;
					[nN])
						break
						;;
					*)
						echo "Please enter Y or N"
			esac
		else
			# Add database
			echo -e "\033[0;36mCreating new database: \033[1;36m$DATABASE_NAME\033[0m"
			mysql -u$NCREATE_MYSQL_USER --password=$NCREATE_MYSQL_PASSWORD -e "create database $DATABASE_NAME"
			break;
		fi
	done

	# Create folders
	if [ "$2" = "wp" ]; then
		echo -e "\033[0;36mCreating new \033[1;32mWordPress\033[0m\033[0;36m site: \033[1;36m$DOMAIN\033[0m"

		$WPCREATE_SCRIPT_PATH/wpcreate.sh "$GLOBAL_WWW_PATH" "$DOMAIN" "$DATABASE_NAME";
		mkdir "$GLOBAL_WWW_PATH/$DOMAIN/logs"
	elif  [ "$2" = "laravel" ]; then
		echo -e "\033[0;36mCreating new \033[1;32mLaravel\033[0m\033[0;36m site: \033[1;36m$DOMAIN\033[0m"

		$NCREATE_SCRIPT_PATH/newLaravel.sh "$GLOBAL_WWW_PATH" "$DOMAIN" "$DATABASE_NAME";
	else
		echo -e "\033[0;36mCreating new site: \033[1;36m$DOMAIN\033[0m"

		$NCREATE_SCRIPT_PATH/newSite.sh "$GLOBAL_WWW_PATH" "$DOMAIN" "$DATABASE_NAME";
	fi

	# Add nginx config
	echo -e "\033[0;36mAdding new nginx config:\033[0m"
	$NCREATE_SCRIPT_PATH/nginx_config_create.sh "$GLOBAL_WWW_PATH" "$DOMAIN" "$2" 'dev' "_www" "_www";

	# Add to hosts
	echo -e "\033[0;36mAdding site to hosts:\033[0m"
	if grep -q "$DOMAIN" "/etc/hosts"; then
		echo -e "\033[0;36mAllready in /etc/hosts\033[0m";
	else
		echo "127.0.0.1    $DOMAIN" | sudo tee -a /etc/hosts;
	fi

	cd "$GLOBAL_WWW_PATH/$DOMAIN/"

	if [ $OPEN_SUBLIME_TEXT = "TRUE" ]; then
		# Open sublime text
		echo -e "\033[0;32mOpening Sublime Text...\033[0m"
		subl "$GLOBAL_WWW_PATH/$DOMAIN/"
	fi
fi

