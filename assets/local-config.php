<?php

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'database_name_here');

/** MySQL database username */
define('DB_USER', 'root');

/** MySQL database password */
define('DB_PASSWORD', 'root');

/** MySQL hostname */
define('DB_HOST', 'localhost');


define('MY_HOSTNAME', 'your-site.dev' );

define('WP_SITEURL', 'http://' . MY_HOSTNAME . '/wordpress');
define('WP_HOME',    'http://' . MY_HOSTNAME );

define('WP_CONTENT_DIR', dirname(__FILE__) . '/content');
define('WP_CONTENT_URL', 'http://' . MY_HOSTNAME . '/content');

define('WP_DEFAULT_THEME', 'wp-template');


/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 */
define('WP_DEBUG', false);

?>
