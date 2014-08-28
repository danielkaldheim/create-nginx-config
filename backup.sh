#!/bin/bash

source ~/.bash_ncreate_config

if [ ! -d "${BACKUPPATH}" ]; then
	mkdir -v -m 755 "${BACKUPPATH}"
fi

# backup mysql

if [ ! -d "${BACKUPPATH}/mysql" ]; then
	mkdir -v -m 755 "${BACKUPPATH}/mysql"
fi

if [ -d "${BACKUPPATH}/mysql" ]; then
	#TARFILE="mysql_"$(date +'%m-%d-%Y')".tar.bz2"
	TARFILE="mysql.tar.bz2"

	mysql --user=$NCREATE_MYSQL_USER --password=$NCREATE_MYSQL_PASSWORD -e 'show databases' | while read dbname; do mysqldump -uroot --password=$NCREATE_MYSQL_PASSWORD --complete-insert $dbname > "${BACKUPPATH}/mysql/${dbname}.sql"; done

	find "${BACKUPPATH}/mysql" -name "*.sql" | tar -cjf "/tmp/${TARFILE}" -T -
	cd "${BACKUPPATH}/mysql" && rm -f *.sql
	mv "/tmp/${TARFILE}" "${BACKUPPATH}/"
fi
