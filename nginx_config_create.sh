#!/bin/bash

# Save script folder
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd)

SITES_AVAILABLE=/usr/local/etc/nginx/sites-available
SITES_ENABLED=/usr/local/etc/nginx/sites-enabled

cd $SITES_AVAILABLE

CONF_NAME="${2}.conf"

# Add composer.json
cp "$SCRIPT_DIR/assets/nginx_vhost_wp.conf" $CONF_NAME

# Fix root
# sed -i '' "s/root \/var\/www/root ${1}/" $CONF_NAME;

# Fix domain
sed -i '' "s/localhost/${2}/" $CONF_NAME;

# Enable site
ln -s $SITES_AVAILABLE/$CONF_NAME $SITES_ENABLED/$CONF_NAME

sudo $SCRIPT_DIR/nginx reload
