#!/bin/bash

SKIPPHPFPM="FALSE"

# Save script folder
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd)

WORDPRESS="FALSE"

DOMAIN=$2

# check the domain is valid!
PATTERN="^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9\_]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$";
if [[ "$DOMAIN" =~ $PATTERN ]]; then
    DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
else
    echo "\033[0;31mInvalid domain name\033[0m"
    exit 1
fi

CONF_NAME="${DOMAIN}.conf"
DIR="$1/${DOMAIN}"
WEBDIR="${DIR}"
LOGDIR="${DIR}/logs"

if [[ -d "${WEBDIR}/public_html" ]]; then
    WEBDIR="$1/${DOMAIN}/public_html";
fi

UPSTREAMNAME=`echo $DOMAIN | tr '[\.]' '[\-]'`
UPSTREAMNAME="$UPSTREAMNAME-socket"

if [[ -z $3 ]]; then
    while true
    do
        echo -e "\033[0;32mIs this site a Wordpress Site? [Y/N] \033[0m"
        read wpyn
        case $wpyn
            in
                [yY])
                    WORDPRESS="TRUE"
                    break
                    ;;
                [nN])
                    break
                    ;;
                *)
                    echo "Please enter Y or N"
        esac
    done
else
    if [[ "$3" = "wp" ]]; then
        WORDPRESS="TRUE"
    fi
fi

# Add php-fpm config
echo $PHP_FPM_POOL_PATH
cd $PHP_FPM_POOL_PATH

if [ -f $CONF_NAME ]; then

    while true
    do
        echo -e "\033[0;31mPHP-FPM config \033[1;31m$CONF_NAME\033[0;31m exists, do you want to overwrite? (y/n) \033[0m"
        read yn
        case $yn
        in
            [yY])
                echo -e "\033[0;36mRemoving old \033[1;36m$CONF_NAME\033[0m"
                rm $CONF_NAME
                break
                ;;
            [nN])
                SKIPPHPFPM="TRUE"
                break
                ;;
            *)
                echo "Please enter Y or N"
        esac
    done
fi

if [ "${SKIPPHPFPM}" = "FALSE" ]; then
    cp -v "$SCRIPT_DIR/assets/php-fpm.conf" $CONF_NAME
    sed -i.bk "s/DOMAIN/${DOMAIN}/g" $CONF_NAME;
    sed -i.bk "s|PATH_TO_WEBDIR|$WEBDIR|g" $CONF_NAME;
    sed -i.bk "s|{USER}|$5|g" $CONF_NAME;
    sed -i.bk "s|{GROUP}|$6|g" $CONF_NAME;
    sed -i.bk "s|{LISTEN_USER}|$NGINX_DEFAULT_USER|g" $CONF_NAME;
    sed -i.bk "s|{LISTEN_GROUP}|$NGINX_DEFAULT_GROUP|g" $CONF_NAME;

    if [[ "$4" = "dev" ]]; then
        sed -i.bk "s|{DISPLAY_ERRORS}|On|g" $CONF_NAME;
    else
        sed -i.bk "s|{DISPLAY_ERRORS}|Off|g" $CONF_NAME;
    fi

    rm "$CONF_NAME.bk"

    if [ -f /etc/init.d/php-fpm ]; then
        sudo /etc/init.d/php-fpm reload
    else
        sudo $SCRIPT_DIR/php-fpm reload
    fi
fi
# Add nginx config
echo $NGINX_VHOST_PATH
cd $NGINX_VHOST_PATH

if [ -f $CONF_NAME ]; then

    while true
    do
        echo -e "\033[0;31mNGINX config \033[1;31m$CONF_NAME\033[0;31m exists, do you want to overwrite? (y/n) \033[0m"
        read yn
        case $yn
        in
            [yY])
                echo -e "\033[0;36mRemoving old \033[1;36m$CONF_NAME\033[0m"
                rm $CONF_NAME
                break
                ;;
            [nN])
                exit 2
                ;;
            *)
                echo "Please enter Y or N"
        esac
    done
fi

cp -v "$SCRIPT_DIR/assets/nginx_vhost.conf" $CONF_NAME

if [[ -f "${WEBDIR}/nginx.conf" ]]; then
        sed -i.bk 18' a\
\    include PATH_TO_WEBDIR/nginx.conf;\
    ' $CONF_NAME;
fi

if [[ $WORDPRESS = "TRUE" ]]; then
    sed -i.bk 19' a\
\    include wordpress.conf;\
    ' $CONF_NAME;
    # if [[ "$4" = "dev" ]]; then
    #     sed -i.bk "s|/public_html||g" $CONF_NAME;
    # fi
fi

if [[ -d "${LOGDIR}" ]]; then
    sed -i.bk 12' a\
\    access_log PATH_TO_LOGDIR/DOMAIN.access.log;\
\    error_log  PATH_TO_LOGDIR/DOMAIN.error.log;\
    ' $CONF_NAME;
fi



if [[ "$4" = "dev" ]]; then
    sed -i.bk "s|www.DOMAIN ||g" $CONF_NAME;
fi

sed -i.bk "s/DOMAIN/${DOMAIN}/g" $CONF_NAME;
sed -i.bk "s/UPSTREAMNAME/${UPSTREAMNAME}/g" $CONF_NAME;
sed -i.bk "s|PATH_TO_WEBDIR|$WEBDIR|g" $CONF_NAME;
sed -i.bk "s|PATH_TO_LOGDIR|$LOGDIR|g" $CONF_NAME;

rm "$CONF_NAME.bk"

if [ -f /etc/init.d/nginx ]; then
    sudo /etc/init.d/nginx reload
else
    sudo $SCRIPT_DIR/nginx reload
fi

