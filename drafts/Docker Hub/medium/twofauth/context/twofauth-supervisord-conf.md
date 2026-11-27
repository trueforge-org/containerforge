# 2FAuth docker/supervisord.conf (tag v9.0.3)

Source URL(s): https://raw.githubusercontent.com/Bubka/2FAuth/v9.0.3/docker/supervisord.conf (fetched 2026-11-27)

- `nodaemon=true`, pidfile `/run/supervisord.pid`, loglevel info.
- Program defaults: stdout/stderr to /dev/stdout and /dev/stderr, `autorestart=false`, `startretries=0`.
- `[program:php-fpm]`: `/usr/sbin/php-fpm84 -F`
- `[program:nginx]`: `/usr/sbin/nginx -g 'daemon off;'`, with `depends_on=php-fpm`.

## Gotchas
- `autorestart=false`: if php-fpm or nginx exits, the container does not restart it.
- `depends_on` is not a standard supervisord key; it is ignored by supervisord.
