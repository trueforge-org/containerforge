# dlandon/zoneminder.unraid: Dockerfile (upstream Docker image, Unraid-oriented)

## Source URL(s) + date
- https://raw.githubusercontent.com/dlandon/zoneminder.unraid/ee9d87e8d1a6e539206f6412109593847eae2d84/Dockerfile (fetched 2026-11-26)
- Plan.md said this page was unreachable; the raw Dockerfile at this commit fetched fine.

## What it is
- Multi-service ZoneMinder image: Apache, PHP-FPM, MariaDB, ZoneMinder (PPA), Tailscale, zmeventnotification files. Base is phusion/baseimage (runit init via `/sbin/my_init`).

## Base / build
- `FROM phusion/baseimage:jammy-1.0.5`, LABEL maintainer "dlandon".
- ENV: `DEBIAN_FRONTEND=noninteractive`, `DISABLE_SSH=true`, `HOME=/root`, `LC_ALL/LANG/LANGUAGE=en_US.UTF-8`, `TZ=Etc/UTC`, `PUID=99`, `PGID=100`, `AUTO_OS_UPDATES=1`, `PHP_VERS=8.4`, `PHP_MIN_VERSION=8.4.27`, `ZM_VERS=1.38`.
- `COPY init/ /etc/my_init.d/`, `COPY defaults/ /root/`, `COPY zmeventnotification/ /root/zmeventnotification/`.

## Install steps (Dockerfile)
- Tailscale apt key/list from `pkgs.tailscale.com/stable/ubuntu/jammy`.
- `add-apt-repository -y ppa:iconnor/zoneminder-$ZM_VERS` and `ppa:ondrej/php`.
- apt install: apache2, mariadb-server, mariadb-client, ssmtp, mailutils, net-tools, wget, sudo, make, tailscale, jq, php8.4 (+fpm, mysql, gd, intl, apcu), libcrypt-mysql-perl, libyaml-perl, libjson-perl, ffmpeg, libvlccore-dev, vlc-bin, vlc-plugin-base, vlc-plugin-video-output, zoneminder, vainfo, i965-va-driver, libva2.
- `adduser www-data video`; `a2enmod proxy_fcgi setenvif ssl rewrite expires headers`; `a2enconf php8.4-fpm zoneminder`.
- CPAN force installs: Net::WebSocket::Server, LWP::Protocol::https, Config::IniFiles, Net::MQTT::Simple, Net::MQTT::Simple::Auth, Config::Tiny.
- `systemd-tmpfiles --create zoneminder.conf`; zoneminder init script moved to `/etc/init.d/zoneminder`.
- `cp /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.cnf`; default-ssl.conf moved into sites-enabled.
- Weekly cron `/etc/cron.weekly/zmaudit` runs `zmaudit.pl -f`.
- Final: PHP-FPM minimum version check (`apt-cache policy`), remove make, autoremove, clean, `rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*`.

## Runtime deps
- Apache + PHP 8.4 FPM, MariaDB (in-container), ZoneMinder 1.38 (PPA), ffmpeg, VLC libs, Tailscale.

## Entrypoint/flags
- `CMD ["/sbin/my_init"]` (phusion init, runs /etc/my_init.d scripts).

## Env vars (ENV in Dockerfile)
| Var | Value |
| --- | --- |
| PUID | 99 |
| PGID | 100 |
| TZ | Etc/UTC |
| AUTO_OS_UPDATES | 1 |
| PHP_VERS | 8.4 |
| PHP_MIN_VERSION | 8.4.27 |
| ZM_VERS | 1.38 |
| DISABLE_SSH | true |

## Ports
- `EXPOSE 80 443 9000` (9000 = zmNinja/websocket per chart).

## Volumes/paths
- `VOLUME ["/config", "/var/cache/zoneminder"]`

## User/UID
- Not set (root, phusion init). PUID/PGID env are the runtime user mapping.

## Healthcheck
- None in Dockerfile.

## Gotchas
- Dockerfile runs `apt-get -y upgrade` twice; PHP-FPM version gate at 8.4.27.
- Upstream installs MariaDB in the same image (multi-service; not a single-process image).
- Tailscale package is in the image.
