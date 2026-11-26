# Dispatcharr/Dispatcharr docker/uwsgi.modular.ini (tag v0.34.1)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/v0.34.1/docker/uwsgi.modular.ini · 2026-11-26

## Options
- `attach-daemon = daphne -b 0.0.0.0 -p 8001 dispatcharr.asgi:application`
- `chdir = /app`, `module = dispatcharr.wsgi:application`, `virtualenv = /dispatcharrpy`, `master = true`
- `env = DJANGO_SETTINGS_MODULE=dispatcharr.settings`, `env = USE_NGINX_ACCEL=true`
- `socket = /app/uwsgi.sock`, `chmod-socket = 777`, `vacuum = true`, `die-on-term = true`
- `static-map = /static=/app/static`
- `workers = $(UWSGI_WORKERS)`
- `http = 0.0.0.0:5656`, `http-keepalive = 1`, `buffer-size = 65536`, `post-buffering = 4096`, `http-timeout = 600`, `socket-timeout = 600`, `lazy-apps = true`
- `gevent = 400`, `gevent-early-monkey-patch = true`, `import = dispatcharr.gevent_patch`
- `thunder-lock = true`, `log-4xx = true`, `log-5xx = true`, `disable-logging = false`
- Logging: `log-master`, `logformat-strftime`, date and format lines per file.
- Commented out: `exec-pre` lines for `/data/logs/uwsgi.log`.

## Notes vs plan.md
- Matches plan.md's uwsgi socket/virtualenv/http/daphne/gevent values. plan.md's sed targets (`socket`, `virtualenv`) are present in this file.
