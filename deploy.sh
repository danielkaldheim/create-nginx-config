#!/bin/bash

USUDO=""
DEPLOY_DIR=$GLOBAL_WWW_PATH;
PUBLIC_HTML="public_html"
USER=$(whoami)

if [ $1 != "global" ]; then
	if id -u $1 >/dev/null 2>&1; then
		USER_HOME=$(eval echo ~${1})
		DEPLOY_DIR="${USER_HOME}/domains/"
		USUDO="sudo -u $1"
		USER=$1

		if [ ! -d $DEPLOY_DIR ]; then
			echo -e "\033[0;36mDeploy dir dosen't exists, creating \033[1;36m$DEPLOY_DIR\033[0m"
			sudo -u $1 mkdir -m 775 $DEPLOY_DIR
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
$USUDO mkdir -m 775 $2
echo -e "\033[0;35m$2\033[0m";

cd $2
$USUDO mkdir -m 775 $PUBLIC_HTML
echo -e "\033[0;35m$PUBLIC_HTML\033[0m";

SITE_DIR=$(pwd)

if [ !$3 ]; then

	AFTER_SLASH=${3##*/}
	PROJECT_NAME="${AFTER_SLASH%%\?*}"
	echo -e "\033[0;36mCreating bare git \033[1;36m$PROJECT_NAME\033[0m"
	echo $SITE_DIR;

	$USUDO mkdir $PROJECT_NAME
	cd $PROJECT_NAME
	git init --bare
	git config core.bare false
	echo -e "\033[0;36mSet worktree \033[1;36m${SITE_DIR}/${PUBLIC_HTML}\033[0m"
	git config core.worktree "${SITE_DIR}/${PUBLIC_HTML}"
	git config receive.denycurrentbranch ignore
	git config core.sharedrepository 1
	git config receive.denyNonFastforwards true

	cd hooks

	if [[ $POST_RECEIVE_SCRIPT_PATH != "" ]]; then
		echo -e "\033[0;36mLinking post receive script\033[0m"
		HOOKS_PATH=$(pwd)
		ln -s $POST_RECEIVE_SCRIPT_PATH "${HOOKS_PATH}/post-receive"
	else
		echo -e "\033[0;36mDownloading post receive script\033[0m"
		curl -o "post-receive" "https://git.crudus.no/server/post-recive/raw/master/post-receive"
		chmod +x post-receive
	fi
	cd ..

	echo -e "\033[0;36mAdd this to your local git repo \033[1;36mgit remote add deploy git+ssh://${USER}@${HOSTNAME}${SITE_DIR}/${PROJECT_NAME}\033[0m"

fi
