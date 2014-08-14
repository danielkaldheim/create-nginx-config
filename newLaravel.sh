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

composer create-project laravel/laravel "${2}" --prefer-dist

# Enter project dir
cd "${2}"

mkdir -v -m 775 logs
sudo chown -v _www:$DEFAULT_ADMIN_GROUP logs

echo '*.log' >> .gitignore
echo '/logs/' >> .gitignore
echo 'app/config/local/' >> .gitignore

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

echo "Working on app/config/local/database.php...";
sed -i.bk -E "s/'database'([[:space:]]*)=> 'homestead'/'database'\1=> '${3}'/g" app/config/local/database.php;
sed -i.bk -E "s/'username'([[:space:]]*)=> 'homestead'/'username'\1=> '${NCREATE_MYSQL_USER}'/g" app/config/local/database.php;
sed -i.bk -E "s/'password'([[:space:]]*)=> 'secret'/'password'\1=> '${NCREATE_MYSQL_PASSWORD}'/g" app/config/local/database.php;
sed -i.bk -E "s/'prefix'([[:space:]]*)=> ''/'prefix'\1=> '${SHORT_SLUG}_'/g" app/config/local/database.php;
rm -f app/config/local/database.php.bk

sed -i.bk "s|'timezone' => 'UTC'|'timezone' => 'Europe/Oslo'|g" app/config/app.php;
sed -i.bk "s|'locale' => 'en'|'locale' => 'nb'|g" app/config/app.php;
rm -f app/config/app.php.bk

rm -f app/config/local/app.php
cp app/config/app.php app/config/local/app.php

sed -i.bk "s|'debug' => false|'debug' => true|g" app/config/local/app.php;
sed -i.bk "s|'url' => 'http://localhost'|'url' => 'http://${2}'|g" app/config/local/app.php;

sed -i.bk "57,\$d" app/config/local/app.php;

#sed -i.bk '57i\'$'\n'');'$'\n' app/config/local/app.php;
echo ');' >> app/config/local/app.php;

rm -f app/config/local/app.php.bk

echo -e "Working on bootstrap/start.php...";
sed -i.bk "s/'local' => array('homestead')/'local' => array('${HOSTNAME}', '${2}', '${3}')/g" bootstrap/start.php;
rm -f bootstrap/start.php.bk

sudo chown -v -R _www:$DEFAULT_ADMIN_GROUP app/storage/
sudo chmod -v -R 775 app/storage/

# git init
git init
git add .
git commit -m "Initial commit."
