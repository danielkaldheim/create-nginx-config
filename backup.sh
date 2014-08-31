#!/bin/bash

source ~/.bash_ncreate_config


if [ ! -z $BACKUPPATH ]; then

	if [ ! -d "${BACKUPPATH}" ]; then
		mkdir -v -m 755 "${BACKUPPATH}"
	fi

	# backup mysql
	if [ ! -d "${BACKUPPATH}/mysql" ]; then
		mkdir -v -m 755 "${BACKUPPATH}/mysql"
	fi

	if [ -d "${BACKUPPATH}/mysql" ]; then
		TARFILE="mysql.tar.bz2"

		mysql --user=$NCREATE_MYSQL_USER --password=$NCREATE_MYSQL_PASSWORD -e 'show databases' | while read dbname; do mysqldump -uroot --password=$NCREATE_MYSQL_PASSWORD --complete-insert $dbname > "${BACKUPPATH}/mysql/${dbname}.sql"; done

		cd "${BACKUPPATH}/mysql"
		find . -name "*.sql" | tar -cjf "/tmp/${TARFILE}" -T -
		rm -f *.sql
		mv "/tmp/${TARFILE}" "${BACKUPPATH}/"
	fi

	# backup nginx
	if [ -d "${NGINX_VHOST_PATH}" ]; then
		TARFILE="nginx.tar.bz2"

		cd "${NGINX_VHOST_PATH}"
		find . -name "*.conf" | tar -cjf "/tmp/${TARFILE}" -T -
		mv "/tmp/${TARFILE}" "${BACKUPPATH}/"
	fi

	# backup php-fpm
	if [ -d "${PHP_FPM_POOL_PATH}" ]; then
		TARFILE="php-fpm.tar.bz2"

		cd "${PHP_FPM_POOL_PATH}"
		find . -name "*.conf" | tar -cjf "/tmp/${TARFILE}" -T -
		mv "/tmp/${TARFILE}" "${BACKUPPATH}/"
	fi

fi
