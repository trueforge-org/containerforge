<?php
// Seeded to /config/config.php by start.sh only when that file is missing or empty.
// Secrets are read from the environment at runtime and are never written to this file.
// UNVERIFIED: the OBSERVIUM_<key> expansion below (double underscore = nested key) follows the
// upstream pvrmza wrapper README; confirm the semantics in a functional test.

$config['db_extension'] = 'mysqli';
$config['db_host'] = getenv('OBSERVIUM_db_host') ?: 'mariadb';
$config['db_name'] = getenv('OBSERVIUM_db_name') ?: 'observium';
$config['db_user'] = getenv('OBSERVIUM_db_user') ?: 'observium';
$config['db_pass'] = getenv('OBSERVIUM_db_pass') ?: 'observiumpwd';

$config['log_dir'] = '/config/logs/';
$config['rrd_dir'] = '/config/rrd/';

// Extra OBSERVIUM_<key> variables become $config['<key>'] ("__" marks a nested array level).
foreach (getenv() as $key => $value) {
    if (strpos($key, 'OBSERVIUM_') !== 0) {
        continue;
    }
    if (in_array($key, ['OBSERVIUM_db_host', 'OBSERVIUM_db_name', 'OBSERVIUM_db_user', 'OBSERVIUM_db_pass', 'OBSERVIUM_ADMIN_USER', 'OBSERVIUM_ADMIN_PASS'], true)) {
        continue;
    }
    $parts = explode('__', substr($key, strlen('OBSERVIUM_')));
    $last = array_pop($parts);
    $ref = &$config;
    foreach ($parts as $part) {
        if (!isset($ref[$part]) || !is_array($ref[$part])) {
            $ref[$part] = [];
        }
        $ref = &$ref[$part];
    }
    $ref[$last] = $value;
    unset($ref);
}
