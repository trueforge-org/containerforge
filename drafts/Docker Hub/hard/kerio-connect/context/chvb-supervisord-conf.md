# chvb/docker-kerio-connect supervisord.conf

Source URL(s): https://raw.githubusercontent.com/chvb/docker-kerio-connect/eb6b9083dd9e9a68e4a67b73c178a0450cecd8ca/etc/supervisor/conf.d/supervisord.conf. Fetched 2026-11-26.

## [supervisord]
- nodaemon=true, runs as root
- logfile `/var/log/supervisord/supervisord.log` (50MB, 10 backups), loglevel error
- pidfile `/var/run/supervisord.pid`; child logs `/var/log/supervisord/`

## Programs
- `[program:sshd]`: `/usr/sbin/sshd -D`
- `[program:kerio]`: `/etc/init.d/kerio-connect.sh`, startsecs 0, autorestart false, startretries 1

## HTTP
- `[inet_http_server]` on `*:9001`, user `admin` with PLAINTEXT password in file (gotcha: exposed on all interfaces)
- `[supervisorctl]` -> `http://127.0.0.1:9001` with same credentials
- No `[unix_http_server]`
