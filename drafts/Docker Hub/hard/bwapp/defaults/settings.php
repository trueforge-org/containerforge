<?php
// Env-driven database settings, loaded before each request via auto_prepend_file.
// The password is read from the environment, so it never lands in a file or on a command line.
// UNVERIFIED: bWAPP's admin/settings.php variable names. Confirm after unzip and align these names.
$db_server   = getenv('DB_HOST') ?: 'mariadb';
$db_port     = getenv('DB_PORT') ?: '3306';
$db_name     = getenv('DB_NAME') ?: 'bwapp';
$db_username = getenv('DB_USER') ?: 'MYMARIADBUSER';
$db_password = getenv('DB_PASS') ?: 'MYMARIADBPASSWORD';
