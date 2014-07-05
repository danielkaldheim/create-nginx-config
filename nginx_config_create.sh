#!/bin/bash

# Save script folder
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd)

cd $NGINX_VHOST_PATH


DOMAIN=$2
# check the domain is valid!
PATTERN="^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$";
if [[ "$DOMAIN" =~ $PATTERN ]]; then
    DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
else
    echo "\033[0;31mInvalid domain name\033[0m"
    exit 1
fi

CONF_NAME="${DOMAIN}.conf"

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
cp "$SCRIPT_DIR/assets/nginx_vhost.conf" $CONF_NAME

if [ "$3" = "wp" ]; then
    sed -i '' 17' a\
        include wordpress.conf;\
    ' $CONF_NAME;
    if [ "$4" = "dev" ]; then
        sed -i '' "s|/public_html||g" $CONF_NAME;
    fi
fi



WEBDIR="$1/${DOMAIN}"
sed -i '' "s/localhost/${DOMAIN}/g" $CONF_NAME;
sed -i '' "s|PATH_TO_WEBDIR|$WEBDIR|g" $CONF_NAME;

sudo $SCRIPT_DIR/nginx reload
