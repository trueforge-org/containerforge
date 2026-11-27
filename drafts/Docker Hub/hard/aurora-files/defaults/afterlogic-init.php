<?php
/*
 * First-run seeding of the database settings (called by start.sh only when config.json is missing).
 * UNVERIFIED: every Aurora call below comes from plan.md and has not been checked against the
 * unpacked aurora-files tree. Check the names (Api::Init, GetSettings, SetValue, Save,
 * SyncModulesConfigs) before the first build run.
 * Values come from the environment only, so they never reach PHP or shell source.
 */

$host = getenv('DB_HOST') ?: '';
$port = getenv('DB_PORT') ?: '3306';
$name = getenv('DB_NAME') ?: 'afterlogic';
$user = getenv('DB_USER') ?: 'afterlogic';
$pass = getenv('DB_PASSWORD') ?: '';

if ($host === '') {
    exit(0);
}

require '/app/www/system/autoload.php';

\Aurora\System\Api::Init(true);
$settings = \Aurora\System\Api::GetSettings();
$settings->SetValue('DBHost', $host . ':' . $port);
$settings->SetValue('DBName', $name);
$settings->SetValue('DBLogin', $user);
$settings->SetValue('DBPassword', $pass);
$settings->Save();
\Aurora\System\Api::SyncModulesConfigs();
