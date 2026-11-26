# Observium docs: install (Debian/Ubuntu) + landing page

Source URL(s): https://docs.observium.org (landing page, fetched; no install facts) · https://docs.observium.org/install_debian/ (fetched) · fetched 2026-11-26

## Supported
- Ubuntu 20.04, 22.04, 24.04, 26.04; Debian 11, 12, 13.
- PHP by release: Ubuntu 26.04 = 8.5, Debian 13 = 8.4, Ubuntu 24.04 = 8.3, Debian 12 = 8.2, Ubuntu 22.04 = 8.1, Debian 11 / Ubuntu 20.04 = 7.4.
- DB: Debian uses MariaDB; Ubuntu uses MySQL (8+ syntax noted).

## Packages (Ubuntu 24.04 / PHP 8.3 example)
- php8.3-cli, -mysql, -gd, -bcmath, -mbstring, -opcache, -curl; php-apcu, php-pear, libapache2-mod-php8.3; php-json on some releases.
- snmp, fping, rrdtool, subversion, whois, mtr-tiny, ipmitool, libvirt-clients, python3-mysqldb, python3-pymysql, python-is-python3, graphviz, imagemagick, apache2, mysql-client/mysql-server (Debian: mariadb-*).
- Debian extra: in /etc/snmp/snmp.conf set `mibs : /opt/observium/mibs/rfc:/opt/observium/mibs/net-snmp`.

## Install flow
- Automated: `bash <(wget -qO- https://www.observium.org/observium_installscript.sh)`.
- Manual: `mkdir -p /opt/observium && cd /opt`; CE tarball `observium-community-latest.tar.gz` from observium.org, `tar zxvf`; then `cd observium`.
- Subscription: SVN trunk or branches/stable.

## Database
- `CREATE DATABASE observium DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;`
- MySQL 8+: `CREATE USER 'observium'@'localhost' identified by '<pw>';` then `GRANT ALL ON observium.* TO 'observium'@'localhost';`
- MariaDB: `GRANT ALL PRIVILEGES ON observium.* TO 'observium'@'localhost' IDENTIFIED BY '<pw>';`

## Config and init
- `cp config.php.default config.php` (at /opt/observium/config.php); set DB user/password.
- Schema: `./discovery.php -u` (some SQL revision errors acceptable).
- Dirs: `mkdir logs` (log_dir configurable); `mkdir rrd && chown www-data:www-data rrd`.
- Admin: `./adduser.php <user> <pass> 10` (level 10 = admin).
- Devices: `./add_device.php <host> <community> v2c`; first runs `./discovery.php -h all`, `./poller.php -h all`.

## Web server (Apache)
- VirtualHost *:80, DocumentRoot /opt/observium/html.
- Directory: `AllowOverride All`, `Require all granted`, `DirectoryIndex index.php`; PHP via `SetHandler application/x-httpd-php`.
- Commands: `a2dismod mpm_event`, `a2enmod mpm_prefork`, `a2enmod php<ver>`, `a2enmod rewrite`.
- Port 80 only; no other ports documented.

## Cron (/etc/cron.d/observium, root)
- Discovery full: `33 */6 * * *` (`observium-wrapper discovery`).
- New-device discovery: every 5 min (`observium-wrapper discovery --host new`).
- Poller: every 5 min (`observium-wrapper poller`); poll interval fixed at 300 s.
- Housekeeping daily: `housekeeping.php -ysel` at 05:13, `-yrptb` at 04:47.

## Updating
- CE: 6-monthly tarball releases. Subscription: SVN updates.

## Landing page (docs.observium.org)
- Only intro text; install details are on sub-pages (merged above).
