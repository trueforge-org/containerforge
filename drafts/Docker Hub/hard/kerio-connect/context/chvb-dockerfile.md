# chvb/docker-kerio-connect Dockerfile (pinned commit)

Source URL(s): https://raw.githubusercontent.com/chvb/docker-kerio-connect/eb6b9083dd9e9a68e4a67b73c178a0450cecd8ca/Dockerfile (blob: https://github.com/chvb/docker-kerio-connect/blob/eb6b9083dd9e9a68e4a67b73c178a0450cecd8ca/Dockerfile). Fetched 2026-11-26.

## Base / ARG
- `FROM ubuntu:14.04` (EOL base)
- ARG `DEBIAN_FRONTEND=noninteractive`; no ENV; MAINTAINER chvb

## RUN
- apt: wget, cryptsetup, dnsutils, resolvconf, sysstat, lsof, openssh-server, supervisor, krb5-kdc, krb5-admin-server
- `/etc/krb5.conf` moved to `/opt/kerio`, symlink back
- Installer: `http://download.kerio.com/dwn/kerio-connect-linux-64bit.deb` (HTTP, unpinned "latest", no checksum); `dpkg -i`, `apt-get install -f`, delete .deb
- Cleanup: apt clean/autoclean/autoremove; rm `/build`, `/tmp/*`, `/var/tmp/*`, `/var/lib/apt/lists/*`, `/etc/dpkg/dpkg.cfg.d/02apt-speedup`
- mkdir `/var/log/supervisord`, `/var/run/sshd`; `locale-gen en_US.utf8`
- User `docker` (home `/home/docker`, group users, secondary sudo); password `test123` via chpasswd (HARDCODED)
- chmod +x `/etc/init.d/kerio-connect.sh`; `mv /opt/kerio /opt-start`

## ADD / COPY
- ADD `/etc/supervisor/conf.d/supervisord.conf` -> same path
- ADD `/etc/init.d/kerio-connect.sh` -> same path
- No COPY, no WORKDIR, no USER (runs as root)

## Entrypoint / ports / volumes
- ENTRYPOINT `["/usr/bin/supervisord"]`, CMD `["-c", "/etc/supervisor/conf.d/supervisord.conf"]`
- VOLUME: `/backup`, `/mailserver/data`, `/opt/kerio`
- EXPOSE: 4040, 22, 25, 465, 587, 110, 995, 143, 993, 119, 563, 389, 636, 80, 443, 5222, 5223 (comment: only 4040 needed for admin)
- No HEALTHCHECK
