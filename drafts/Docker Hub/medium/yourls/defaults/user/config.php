<?php
// YOURLS configuration for ContainerForge. Copied to /config only when missing.
// Values are read from environment variables on every request, so changes apply on restart.
if ( !defined( 'YOURLS_ABSPATH' ) ) {
	die();
}

define( 'YOURLS_DB_USER', getenv( 'YOURLS_DB_USER' ) ?: 'yourls' );
define( 'YOURLS_DB_PASS', getenv( 'YOURLS_DB_PASS' ) ?: '' );
define( 'YOURLS_DB_NAME', getenv( 'YOURLS_DB_NAME' ) ?: 'yourls' );
define( 'YOURLS_DB_HOST', getenv( 'YOURLS_DB_HOST' ) ?: 'localhost' );
define( 'YOURLS_DB_PREFIX', getenv( 'YOURLS_DB_PREFIX' ) ?: 'yourls_' );

define( 'YOURLS_SITE', rtrim( getenv( 'YOURLS_SITE' ) ?: 'http://localhost:8080', '/' ) );
define( 'YOURLS_LANG', '' );
define( 'YOURLS_UNIQUE_URLS', true );
define( 'YOURLS_PRIVATE', filter_var( getenv( 'YOURLS_PRIVATE' ) ?: 'true', FILTER_VALIDATE_BOOLEAN ) );
define( 'YOURLS_COOKIEKEY', getenv( 'YOURLS_COOKIEKEY' ) ?: '' );
define( 'YOURLS_URL_CONVERT', 36 );
define( 'YOURLS_DEBUG', false );
