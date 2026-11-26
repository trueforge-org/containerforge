# osixia/docker-phpLDAPadmin image/Dockerfile (legacy v1.2.5 image)

Source URL: https://raw.githubusercontent.com/osixia/docker-phpLDAPadmin/master/image/Dockerfile (fetched; master, unpinned)
Blob URL in urls.txt: https://github.com/osixia/docker-phpLDAPadmin/blob/master/image/Dockerfile

## Base / args
- FROM osixia/web-baseimage:release-1.2.0-dev
- ARG PHPLDAPADMIN_VERSION=1.2.5

## Single package/setup RUN
- apt update; add-multiple-process-stack; add-service-available :apache2 :php7.3-fpm :ssl-tools
- apt install (no recommends): ca-certificates, curl, php7.3-ldap, php7.3-readline, php7.3-xml
- curl tarball of leenooks/phpLDAPadmin at $PHPLDAPADMIN_VERSION from GitHub
- mkdir /var/www/phpldapadmin_bootstrap and /var/www/phpldapadmin; extract bootstrap (strip top dir)
- purge curl, ca-certificates; delete tarball; clean apt/lists/tmp

## Files
- service -> /container/service; environment -> /container/environment/99-default
- RUN /container/tool/install-service

## Runtime
- ENV: none set directly (defaults from environment dir, not shown)
- EXPOSE 80 443
- VOLUME /var/www/phpldapadmin
- USER/WORKDIR/ENTRYPOINT/CMD/HEALTHCHECK: inherited from base (s6 init style)
- Stack: apache2 + php7.3-fpm supervised; ssl-tools available

## Gotchas
- PHP 7.3 base (EOL). Legacy image; osixia README says deprecated.
