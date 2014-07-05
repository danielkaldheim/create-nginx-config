#!/bin/bash

# Save script folder
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd)

cd $NGINX_VHOST_PATH

CONF_NAME="${2}.conf"

if [ -f $CONF_NAME ]; then

    echo -e "\033[0;31mConfig \033[1;31m$CONF_NAME\033[0;31m exists, do you want to overwrite? (y/n) \033[0m"
    read yn

    if [ "$yn" = "y" ]; then
        rm $CONF_NAME
    else
        exit 0
    fi

fi

# Add nginx config
if [ "$3" = "wp" ]; then
    cp "$SCRIPT_DIR/assets/nginx_vhost_wp.conf" $CONF_NAME
else
    cp "$SCRIPT_DIR/assets/nginx_vhost.conf" $CONF_NAME
fi

sed -i '' "s/localhost/${2}/" $CONF_NAME;

OLDPATH="/var/www"
if [ $OLDPATH != $1 ]; then
    sed -i "s|$OLDPATH|$1|g" $CONF_NAME
fi

sudo $SCRIPT_DIR/nginx reload
