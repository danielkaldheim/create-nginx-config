#!/bin/bash

source ~/.bash_ncreate_config

USUDO=""
DEPLOY_DIR=$GLOBAL_WWW_PATH;
PUBLIC_HTML="public_html"
USER=nginx

if [ -z $1 ]; then
	echo -e "\033[0;31mNo \033[1;31muser\033[0;31m name given\033[0m"
	exit 1
fi

if [ -z $2 ]; then
	echo -e "\033[0;31mNo \033[1;31mdomain\033[0;31m name given\033[0m"
	exit 1
fi

DOMAIN=$2
# check the domain is valid!
PATTERN="^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$";
if [[ "$DOMAIN" =~ $PATTERN ]]; then
	DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
else
	echo "\033[0;31minvalid domain name\033[0m"
	exit 1
fi

if [ $1 != "global" ]; then
	if id -u $1 >/dev/null 2>&1; then
		USER_HOME=$(eval echo ~${1})
		DEPLOY_DIR="${USER_HOME}/domains/"
		USER=$1

		if [ ! -d $DEPLOY_DIR ]; then
			echo -e "\033[0;36mDeploy dir dosen't exists, creating \033[1;36m$DEPLOY_DIR\033[0m"
			mkdir -v -m 775 $DEPLOY_DIR
			chown -v $USER:adm $DEPLOY_DIR
		fi

	else
		echo -e "\033[0;31mUser \033[1;31m${1}\033[0;31m dosen't exists!\033[0m";
		exit 2
	fi
fi

cd $DEPLOY_DIR;

if [ -d $2 ]; then
	echo -e "\033[0;31mSite \033[1;31m${2}\033[0;31m exists, abort!\033[0m";
	exit 2
fi

echo -e "\033[0;36mCreating sites directories\033[0m";
mkdir -v -m 775 $2
chown -v $USER:adm $2

cd $2
mkdir -v -m 775 $PUBLIC_HTML
chown -v $USER:adm $PUBLIC_HTML

mkdir -v -m 775 logs
chown -v $USER:adm logs

SITE_DIR=$(pwd)

if [ $3 ]; then

	AFTER_SLASH=${3##*/}
	PROJECT_NAME="${AFTER_SLASH%%\?*}"
	echo -e "\033[0;36mCreating bare git repo \033[1;36m$PROJECT_NAME\033[0m"

	mkdir -v $PROJECT_NAME

	# Go into git repo
	cd $PROJECT_NAME

	git init --bare
	git config core.bare false
	echo -e "\033[0;36mSet git repo worktree \033[1;36m${SITE_DIR}/${PUBLIC_HTML}\033[0m"
	git config core.worktree "${SITE_DIR}/${PUBLIC_HTML}"
	git config receive.denycurrentbranch ignore
	git config core.sharedrepository 1
	git config receive.denyNonFastforwards true

	chown -R $USER:adm .

	# Go into hooks
	cd hooks

	if [ $POST_RECEIVE_SCRIPT_PATH != "" ]; then
		echo -e "\033[0;36mLinking post receive script\033[0m"
		HOOKS_PATH=$(pwd)
		ln -v -s $POST_RECEIVE_SCRIPT_PATH "${HOOKS_PATH}/post-receive"
	else
		echo -e "\033[0;36mDownloading post receive script\033[0m"
		curl -k -o "post-receive" "https://git.crudus.no/server/post-recive/raw/master/post-receive"
		chmod -v +x post-receive
	fi

	# Go out of hooks
	cd ..

	echo -e "\033[0;36mAdd this to your local git repo \033[1;36mgit remote add deploy git+ssh://${USER}@${HOSTNAME}${SITE_DIR}/${PROJECT_NAME}\033[0m"

fi

# Add nginx config
echo -e "\033[0;36mAdding new nginx config:\033[0m"
$NCREATE_SCRIPT_PATH/nginx_config_create.sh "$DEPLOY_DIR" $DOMAIN '' '' $USER 'adm';

# Add to hosts
echo -e "\033[0;36mAdding site to hosts:\033[0m"
if grep -q $DOMAIN "/etc/hosts"; then
	echo -e "\033[0;36mAllready in /etc/hosts\033[0m";
else
	echo "127.0.0.1    $DOMAIN" | sudo tee -a /etc/hosts;
fi

DATABASE_NAME=`echo $DOMAIN | tr '[\.]' '[_]'`
if [[ $1 != "global" ]]; then
	DATABASE_NAME="${USER}_${DATABASE_NAME}"
fi

while true
do
	echo -e "\033[0;32mDo you want to create database? [Y/N] \033[0m"
	read yn
	case $yn
		in
			[yY])
				echo -e "\033[0;32mWhat will the database be named? (press enter for \033[1;32m$DATABASE_NAME\033[0;32m) \033[0m"
				read DB
				if [[ ! -z $DB ]]; then
					DATABASE_NAME=$DB
				fi

				# Add database
				echo -e "\033[0;36mCreating new database: \033[1;36m$DATABASE_NAME\033[0m"
				mysql -u$NCREATE_MYSQL_USER --password=$NCREATE_MYSQL_PASSWORD -e "create database $DATABASE_NAME"
				break
				;;
			[nN])
				break
				;;
			*)
				echo "Please enter Y or N"
	esac
done
