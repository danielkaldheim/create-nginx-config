#!/bin/bash

# Save script folder
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd)

# Get short slug
SHORT_SLUG=${2:0:2};

# Goto hosts dir
cd "${1}"

# Check if project dir exists
# If not, create it
if [ ! -d "${2}" ]; then
	mkdir -v -m 775 "${2}"
fi

if [ ! -z "$4" ]; then

	$NCREATE_SCRIPT_PATH/gitPublish.sh "${1}" $4 $2

	cd "${2}"
	pwd

	if [ -d public ]; then
		mv -v public/ public_html

		echo -e "Working on bootstrap/paths.php...";
		sed -i.bk "s|'public' => __DIR__.'/../public'|'public' => __DIR__.'/../public_html'|g" bootstrap/paths.php;
		rm -f bootstrap/paths.php.bk
	fi

	if [ ! -f public_html/nginx.conf ]; then
		# Add a blank nginx config
		touch public_html/nginx.conf

		cat >public_html/nginx.conf <<EOL
location / {
    try_files \$uri \$uri/ /index.php?\$query_string;
}
EOL
	fi

else

	# Enter project dir
	cd "${2}"

	composer create-project laravel/laravel . --prefer-dist

	echo '*.log' >> .gitignore
	echo '/logs/' >> .gitignore
	echo 'app/config/local/' >> .gitignore
	echo 'app/storage/' >> .gitignore

	mv -v public/ public_html

	echo -e "Working on bootstrap/paths.php...";
	sed -i.bk "s|'public' => __DIR__.'/../public'|'public' => __DIR__.'/../public_html'|g" bootstrap/paths.php;
	rm -f bootstrap/paths.php.bk

	# Add a blank nginx config
	touch public_html/nginx.conf

	cat >public_html/nginx.conf <<EOL
location / {
    try_files \$uri \$uri/ /index.php?\$query_string;
}
EOL

	mkdir -v -m 775 app/lang/nb
	cd app/lang/nb

	wget https://raw.githubusercontent.com/caouecs/Laravel4-lang/master/nb/pagination.php
	wget https://raw.githubusercontent.com/caouecs/Laravel4-lang/master/nb/reminders.php
	wget https://raw.githubusercontent.com/caouecs/Laravel4-lang/master/nb/validation.php

	cd ../../../

	# Add autocomplete to artisan
	cd app/commands
	wget https://raw.githubusercontent.com/janka/artisanBashCompletion/master/listForBash.php
	cd ../../

	echo 'Artisan::add(new listForBash);' >> app/start/artisan.php

	sed -i.bk "s|'timezone' => 'UTC'|'timezone' => 'Europe/Oslo'|g" app/config/app.php;
	sed -i.bk "s|'locale' => 'en'|'locale' => 'nb'|g" app/config/app.php;
	rm -f app/config/app.php.bk


	# git init
	git init
	git add .
	git commit -m "Initial commit."

	echo -e "Adding more composer stuff"

	## CRUDUS CMS
	composer config repositories.crudus composer http://packages.crudus.no
	composer require codesleeve/asset-pipeline:dev-master crudus/cms:dev-master
	composer require way/generators:2.* --dev

	rm -v app/models/User.php

	php artisan dump-autoload
	#php artisan migrate --package="Crudus/Cms"

	git commit -am "Added crudus/cms to project"
fi

# Remove old local configs
if [ -f app/config/local/app.php ]; then
	rm -f app/config/local/app.php
fi


if [ ! -d app/config/local ]; then
	mkdir -v -m 775 app/config/local
fi

cp app/config/app.php app/config/local/app.php

sed -i.bk "s|'debug' => false|'debug' => true|g" app/config/local/app.php;
sed -i.bk "s|'url' => 'http://localhost'|'url' => 'http://${2}'|g" app/config/local/app.php;

sed -i.bk "57,\$d" app/config/local/app.php;

#sed -i.bk '57i\'$'\n'');'$'\n' app/config/local/app.php;
echo ');' >> app/config/local/app.php;
rm -f app/config/local/app.php.bk

echo "Working on app/config/local/database.php...";
if [ ! -f app/config/local/database.php ]; then
	cp app/config/database.php app/config/local/database.php
fi
sed -i.bk -E "s/'database'([[:space:]]*)=> '(.*)'/'database'\1=> '${3}'/g" app/config/local/database.php;
sed -i.bk -E "s/'username'([[:space:]]*)=> '(.*)'/'username'\1=> '${NCREATE_MYSQL_USER}'/g" app/config/local/database.php;
sed -i.bk -E "s/'password'([[:space:]]*)=> '(.*)'/'password'\1=> '${NCREATE_MYSQL_PASSWORD}'/g" app/config/local/database.php;
sed -i.bk -E "s/'prefix'([[:space:]]*)=> '(.*)'/'prefix)'\1=> '${SHORT_SLUG}_'/g" app/config/local/database.php;
rm -f app/config/local/database.php.bk


echo -e "Working on bootstrap/start.php...";
sed -i.bk -E "s/'local' => array((.*)[^\)])/'local' => array('${HOSTNAME}', '${2}', '${3}')/g" bootstrap/start.php;
rm -f bootstrap/start.php.bk

# fix storage
if [ ! -d app/storage ]; then
	mkdir -v app/storage
fi

sudo chown -v -R _www:$DEFAULT_ADMIN_GROUP app/storage
sudo chmod -v -R 775 app/storage

mkdir -v -m 775 logs
sudo chown -v _www:$DEFAULT_ADMIN_GROUP logs

php artisan dump-autoload
