#!/bin/bash

source ~/.bash_ncreate_config

# Save script folder
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd)

if [[ ! -z $1 ]]; then

	DOMAIN="${1}";


	# check the domain is valid!
	PATTERN="^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9\_]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$";
	if [[ "$DOMAIN" =~ $PATTERN ]]; then
	    DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
	else
	    echo -e "\033[0;31mInvalid domain name\033[0m"
	    exit 1
	fi

	if [ -d "$GLOBAL_WWW_PATH/$DOMAIN" ]; then

		if [ -d "$GLOBAL_WWW_PATH/$DOMAIN/public_html" ]; then
			cd "$GLOBAL_WWW_PATH/$DOMAIN/public_html"

			if [[ "$(git status --porcelain 2>/dev/null)" = *\?\?* ]]; then
				while true
				do
					echo -e "\033[0;32mProject has uncomited files, still want to remove project? [Y/N]?\033[0m"
					read yn
					case $yn
						in
							[yY])
								break
								;;
							[nN])
								exit 0
								break
								;;
							*)
								echo "Please enter Y or N"
					esac
				done
			fi

			cd ../..
		fi

		echo -e "Removing ${GLOBAL_WWW_PATH}/${DOMAIN} ...";
		rm -rf "${GLOBAL_WWW_PATH}/${DOMAIN}"
	fi

	DATABASE_NAME=`echo $DOMAIN | tr '[\.]' '[_]'`
	while true
	do
		echo -e "\033[0;32mDo you want to remove database [Y/N]?\033[0m"
		read yn
		case $yn
			in
				[yY])
					echo -e "\033[0;32mWhat is the database name? (press enter for \033[1;32m$DATABASE_NAME\033[0;32m) \033[0m"
					read DB
					if [[ ! -z $DB ]]; then
						DATABASE_NAME=$DB
					fi

					RESULT=`mysqlshow --user=$NCREATE_MYSQL_USER --password=$NCREATE_MYSQL_PASSWORD $DATABASE_NAME| grep -v Wildcard | grep -o $DATABASE_NAME`
					if [ "$RESULT" == "$DATABASE_NAME" ]; then
						echo -e "\033[0;32mRemoving database\033[0m";
						mysqladmin -u$NCREATE_MYSQL_USER -p$NCREATE_MYSQL_PASSWORD drop "${DATABASE_NAME}"
					else
						echo -e "\033[0;32mDatabase don't exists\033[0m";
					fi
					break
					;;
				[nN])
					break
					;;
				*)
					echo "Please enter Y or N"
		esac

	done

	CONF_NAME="${DOMAIN}.conf"

	if [ -f "${PHP_FPM_POOL_PATH}/${CONF_NAME}" ]; then
		echo -e "\033[0;32mRemoving: \033[0m";
		rm -v "${PHP_FPM_POOL_PATH}/${CONF_NAME}";
	fi

	if [ -f /etc/init.d/php-fpm ]; then
        sudo /etc/init.d/php-fpm reload
    else
        sudo $SCRIPT_DIR/php-fpm reload
    fi

	if [ -f "${NGINX_VHOST_PATH}/${CONF_NAME}" ]; then
		echo -e "\033[0;32mRemoving: \033[0m";
		rm -v "${NGINX_VHOST_PATH}/${CONF_NAME}";
	fi

	if [ -f /etc/init.d/nginx ]; then
	    sudo /etc/init.d/nginx reload
	else
	    sudo $SCRIPT_DIR/nginx reload
	fi

	if grep -q "$DOMAIN" "/etc/hosts"; then
		echo -e "\033[0;36mRemove $DOMAIN from /etc/hosts\033[0m";
		sudo sed -i '' "/${DOMAIN}/d" /etc/hosts;
	fi

else
	echo "Usage: ndelete example.com";

fi
