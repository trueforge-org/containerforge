# pvrmza/docker-observium README (third-party wrapper)

Source URL(s): https://github.com/pvrmza/docker-observium (raw README) · fetched 2026-11-26

## Image
- Packages Observium CE 23.9 (per wrapper README, 2023-09-20). Stale vs current CE; not the version to use.
- Needs separate MariaDB container. Example uses mariadb:10.5.2.
- Run: manual docker run for both containers, or clone repo, copy `env_mysql_example` -> `.env_mysql`, `env_observium_example` -> `.env_observium`, `docker-compose up -d`.

## Env vars
| Name | Default | Meaning |
|---|---|---|
| OBSERVIUM_<key> | - | Written into config.php as `$config['<key>']`; `__` = nested array level (e.g. `OBSERVIUM_snmp__community__0`) |
| OBSERVIUM_db_host | db | DB host |
| OBSERVIUM_db_name | observium | DB name |
| OBSERVIUM_db_user | observium | DB user |
| OBSERVIUM_db_pass | observiumpwd | DB password |
| OBSERVIUM_ADMIN_USER | admin | Admin user |
| OBSERVIUM_ADMIN_PASS | admin | Admin password |
- Full defaults in repo `files/defaults.inc.php`.
- phpIPAM (no prefix): phpipam_url, observium_url, phpipam_api, phpipam_key, phpipam_default_section.
- Config export: download `export_config.php` to /opt/observium, chmod +x, run to produce env file.

## Ports / volumes
- Exposes 80 and 443 (example maps host 8080 -> 80).
- `/config` volume: `/config/hosts` (merged into /etc/hosts, then added to Observium); `/config/devices` (bulk import, one per line).
  - v2c: `<host> [community] [v1|v2c] [port] [udp|udp6|tcp|tcp6]`
  - v3: `<host> [any|nanp|anp|ap] [v3] [user] [password] [enckey] [md5|sha] [aes|des] [port] [transport]`
- DB container data: /var/lib/mysql.

## Linked DB
- MariaDB first with MYSQL_ROOT_PASSWORD, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE, TZ; app `--link observium_db:db`.
- App OBSERVIUM_db_user/pass/name must match MYSQL_USER/PASSWORD/DATABASE.

## Startup behaviour
- Writes config.php from OBSERVIUM_* at start.
- Imports /config/hosts and /config/devices.
- Creates admin from OBSERVIUM_ADMIN_USER/PASS.
- DB schema init not described.

## Gotchas
- Default admin/admin and sample DB passwords must be changed.
- Old MariaDB example (10.5.2); `--link` legacy.
- Doc typo "mkidr".
