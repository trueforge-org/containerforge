# adferrand/docker-backuppc Dockerfile + entrypoint (commit cf90ead82e93b0af92f4d6d1f0ae28b6ff1c1a69)

Source URL(s) + date: https://raw.githubusercontent.com/adferrand/docker-backuppc/cf90ead82e93b0af92f4d6d1f0ae28b6ff1c1a69/Dockerfile ; .../files/entrypoint.sh (fetched 2026-11-27)

## Base / build args
- `FROM docker.io/alpine:3.24.4` (Alpine, musl).
- ARG/ENV: BACKUPPC_VERSION=4.4.0, BACKUPPC_XS_VERSION=0.62, RSYNC_BPC_COMMIT=1ad3f70.

## Build (Dockerfile)
- Runtime apk: rsync tar bash shadow ca-certificates supervisor patch perl (+ perl-archive-zip, perl-xml-rss, perl-cgi, perl-file-listing, perl-json-xs, perl-time-parsedate), expat samba-client iputils openssh openssl rrdtool ttf-dejavu msmtp lighttpd lighttpd-mod_auth apache2-utils tzdata libstdc++ libgomp gzip pigz.
- par2cmdline from Alpine edge community repo (`-X http://dl-cdn.alpinelinux.org/alpine/edge/community`).
- Build deps (virtual, removed after): gcc g++ autoconf automake make git perl-dev acl-dev curl.
- BackupPC::XS: `git clone https://github.com/backuppc/backuppc-xs.git` branch 0.62, `perl Makefile.PL && make && make test && make install`.
- rsync-bpc: `git clone https://github.com/backuppc/rsync-bpc.git`, checkout 1ad3f70, `./configure --disable-md2man --disable-openssl --disable-xxhash --disable-zstd --disable-lz4 && make install`.
- msmtp replaces sendmail (`/usr/sbin/sendmail -> /usr/bin/msmtp`).
- SSH: StrictHostKeyChecking no.
- BackupPC tarball downloaded at build to /root/BackupPC-4.4.0.tar.gz from github releases (installed at runtime by entrypoint). `touch /firstrun`.
- COPY: files/lighttpd.conf, auth.conf, auth-ldap.conf, entrypoint.sh (/entrypoint.sh), supervisord.conf (/etc/supervisord.conf), datadumper.patch, xss-cgi-view.patch.

## Runtime
- `EXPOSE 8080`, `WORKDIR /home/backuppc`.
- `VOLUME ["/etc/backuppc", "/home/backuppc", "/data/backuppc"]`.
- `ENTRYPOINT ["/entrypoint.sh"]`, `CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]`.
- No HEALTHCHECK, no USER directive (root).

## Entrypoint (files/entrypoint.sh, 149 lines)
- Env: BACKUPPC_UUID (default 1000), BACKUPPC_GUID (default 1000). Looks up user/group by ID, creates `backuppc` user/group if missing (useradd -r -d /home/backuppc -M -N).
- On first run (`/firstrun` present): optional TZ; generates SSH key `/home/backuppc/.ssh/id_rsa` if missing; extracts BackupPC tarball and runs its installer (config override CgiAdminUsers).
- Web auth: htpasswd at /etc/backuppc/htpasswd. Defaults BACKUPPC_WEB_USER=backuppc, BACKUPPC_WEB_PASSWD=password (created only if file missing).
- USE_SSL=true: generates /etc/lighttpd/server.pem if absent, enables mod_openssl.
- AUTH_METHOD=ldap: fills LDAP_HOSTNAME, LDAP_STARTTLS, LDAP_BASE_DN, LDAP_FILTER, LDAP_BIND_DN, LDAP_BIND_PW, LDAP_BACKUPPC_ADMIN into auth-ldap.conf.
- msmtp config /etc/msmtprc: SMTP_HOST (default mail.example.org), SMTP_MAIL_DOMAIN optional; log /var/log/msmtp.log.
- Chowns /home/backuppc, /var/log/lighttpd, logs to backuppc user.
- Cleanup: removes tarball, extracted dir and /firstrun. Then `exec "$@"`.

## Env (summary)
| Env | Default |
| --- | --- |
| BACKUPPC_UUID / BACKUPPC_GUID | 1000 / 1000 |
| TZ | unset |
| BACKUPPC_WEB_USER / BACKUPPC_WEB_PASSWD | backuppc / password (first run only) |
| USE_SSL | unset (true enables TLS) |
| AUTH_METHOD | unset (ldap enables LDAP) |
| LDAP_* | unset |
| SMTP_HOST / SMTP_MAIL_DOMAIN | mail.example.org / unset |

## Gotchas
- Runtime install of BackupPC on first start writes into /etc/backuppc, /home/backuppc, /data/backuppc (read-only-rootfs needs those as volumes/tmpfs).
- Upstream pins RSYNC_BPC commit (3.1.3.0 tag does not build on GCC 14/15).
- Patches datadumper.patch and xss-cgi-view.patch are marked TODO for BackupPC 4.4.1.
