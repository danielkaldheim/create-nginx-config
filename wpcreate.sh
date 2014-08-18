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
	mkdir "${2}"
fi

# Enter project dir
cd "${2}"

mkdir -v logs

if [ ! -z "$4" ]; then

	$NCREATE_SCRIPT_PATH/gitPublish.sh "${1}/${2}" $4 public_html
	cd public_html

	if [ ! -f nginx.conf ]; then
		# Add a blank nginx config
		touch nginx.conf
	fi

else

	mkdir -v public_html
	cd public_html

	# Init Git, create README.md and make first commit
	git init
	touch README.md

	echo "# ${2}" >> README.md

	git add README.md
	git commit -m "Initial commit."

	# Add .gitignore
	cp "$SCRIPT_DIR/assets/.gitignore_wp" .gitignore
	git add .gitignore
	git commit -m "Add .gitignore."

	# Add a blank nginx config
	touch nginx.conf

	# Add composer.json
	cp "$SCRIPT_DIR/assets/composer.json" .

	# Search and replace project name
	if [ -n "$3" ]; then
		sed -i '' "s/project-name/${3}/" composer.json;
	else
		sed -i '' "s/project-name/${2}/" composer.json;
	fi

	# Check composer version
	composerversion=$(composer --version)

	if [[ "$composerversion" =~ "/usr/bin/composer self-update" ]]
	then
		sudo /usr/bin/composer self-update
	fi

	# Install dependencies
	composer install

	# Add composer config to git
	git add composer.json composer.lock
	git commit -m "Install composer dependencies"

	# Create wp-config in root
	cp wordpress/wp-config-sample.php wp-config.php
	git add wp-config.php
	git commit -m "Adding default wp-config.php file"

	# Edit wp-config.php
	sed -i '' '74,82d' wp-config.php
	sed -i '' '17,28d' wp-config.php
	sed -i '' 16' a\
	require_once(dirname(__FILE__) . "/" . "vendor/autoload.php");\
	' wp-config.php;
	sed -i '' 17' a\
	require_once(dirname(__FILE__) . "/" . "local-config.php");\
	' wp-config.php;
	sed -i '' "s/define('WPLANG', '');/define('WPLANG', 'nb_NO');/" wp-config.php;
	sed -i '' "s/define('ABSPATH', dirname(__FILE__) . '\/');/define('ABSPATH', dirname(__FILE__) . '\/wordpress\/');/" wp-config.php;
	sed -i '' "s/$table_prefix  = 'wp_';/$table_prefix  = '${SHORT_SLUG}_';/" wp-config.php;

	# Update salts in wp-config.php
	SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/);
	sed -i '' '35,42d' wp-config.php;
	printf '%s\n' H 35i "" . wq | ed -s wp-config.php;
	printf '%s\n' H 36i "$SALT" . wq | ed -s wp-config.php;

	sed -i '' 69' a\
	if ( !defined("WP_DOCUMENT_ROOT") )\
		define("WP_DOCUMENT_ROOT", dirname(__FILE__) . "/" );\
	if ( !defined( "WP_LANG_DIR" ) )\
		define( "WP_LANG_DIR", ABSPATH . "/wp-content" . "/languages" );\
	' wp-config.php;

	git commit -am "Update wp-config.php"

	# Copy index.php to root
	cp wordpress/index.php .
	sed -e "s/require( dirname( __FILE__ ) . '\/wp-blog-header.php' );/require( dirname( __FILE__ ) . '\/wordpress\/wp-blog-header.php' );/" wordpress/index.php > index.php
	git add index.php
	git commit -m "Added index.php and pointed to correct location"

fi

# Add local-config.php
cp "$SCRIPT_DIR/assets/local-config.php" .

# Edit local-config.php
sed -i '' "s/define('MY_HOSTNAME', 'your-site.dev' );/define('MY_HOSTNAME', '${2}' );/" local-config.php;

if [ -n "$3" ]; then
	sed -i '' "s/define('DB_NAME', 'database_name_here');/define('DB_NAME', '${3}');/" local-config.php;
else
	sed -i '' "s/define('DB_NAME', 'database_name_here');/define('DB_NAME', '${2}');/" local-config.php;
fi
