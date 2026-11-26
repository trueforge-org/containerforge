# pvrmza/docker-observium Dockerfile (third-party wrapper)

Source URL(s): https://github.com/pvrmza/docker-observium/blob/312a90f0a42394f024cc78b0997375f580649f64/Dockerfile (raw fetched) · fetched 2026-11-26

- `FROM ubuntu:22.04`; `ENV DEBIAN_FRONTEND=noninteractive`; maintainer LABEL present.
- RUN: `apt-get update && apt-get dist-upgrade -y`; install libapache2-mod-php, php-cli, php-mysql, php-mysqli, php-gd, php-json, php-curl, php-pear, php-apcu, php-ldap, snmp, fping, mysql-client, python3-mysqldb, rrdtool, subversion, whois, mtr-tiny, ipmitool, graphviz, imagemagick, apache2, python3-pymysql, python-is-python3, libvirt-clients, wget, supervisor, cron, unzip.
- Cleanup: apt-get clean/autoclean/autoremove; rm /var/lib/apt/lists/*, /tmp/*, /var/tmp/*, /var/lib/cache/*, /var/lib/log/*.
- COPY files/apache-observium.conf -> /etc/apache2/sites-enabled/000-default.conf
- COPY files/cron-observium -> /etc/cron.d/observium (chmod 0644)
- COPY files/supervisord.conf -> /etc/supervisord.conf
- COPY files/docker-entrypoint.sh -> /usr/local/bin/ (chmod +x)
- a2dismod mpm_event; a2enmod mpm_prefork; a2enmod php8.1; a2enmod rewrite.
- Appends TLS_REQCERT never to /etc/ldap/ldap.conf.
- Download: `cd /opt; wget -c http://www.observium.org/observium-community-latest.tar.gz; tar zxvf; rm` (unpinned "latest").
- `VOLUME /config`; `EXPOSE 80`; `ENTRYPOINT /usr/local/bin/docker-entrypoint.sh`.
- No ADD, WORKDIR, USER, CMD.
- Entrypoint, cron, supervisord, apache conf contents not shown (in files/, not fetched).
