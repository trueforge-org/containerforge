# MediaGoblin deploying docs

**Source:** https://docs.mediagoblin.org/en/stable/siteadmin/deploying.html (fetched 2026-11-26)

## Runtime
- Python 3.7+. Core: git, SQLite or PostgreSQL, Pillow, Node.js.
- Tested: Debian 11/12/13, Ubuntu 22.04/24.04, Fedora 43.

## System packages
- Debian: automake git nodejs npm pkgconf python3-dev python3-venv python3-gst-1.0 python3-pil
- Fedora: automake gcc git-core make nodejs npm libffi-devel pkgconf python3-devel python3-pillow
- Prod extras: Debian nginx-light rabbitmq-server; Fedora nginx rabbitmq-server
- PostgreSQL: Debian postgresql python3-psycopg2; Fedora postgresql postgresql-server python3-psycopg2 (+ initdb)

## Install
```
git clone --depth=1 https://git.sr.ht/~mediagoblin/mediagoblin --branch stable --recursive
cd mediagoblin
./autogen.sh
./configure
make
mkdir --mode=2750 user_dev
```
- Dedicated user `mediagoblin` (home /var/lib/mediagoblin), group www-data (Debian) or nginx (Fedora).

## Config files
- mediagoblin.ini: email_sender_address; optional direct_remote_path, base_dir, base_url
- PostgreSQL: uncomment `sql_engine = postgresql:///mediagoblin` in [mediagoblin]
- paste.ini: used by paster service

## Database / admin
- Default SQLite; `./bin/gmg dbupdate`
- `./bin/gmg adduser --username you --email you@example.com`; `./bin/gmg makeadmin you`

## Server commands / ports
- Test: `./lazyserver.sh --server-name=broadcast` (port 6543)
- Behind nginx: `./lazyserver.sh --server-name=main`; nginx :80 proxies to 127.0.0.1:6543
- Systemd paster: `bin/paster serve paste.ini --log-file=/var/log/mediagoblin/mediagoblin.log --server-name=main`
- Systemd celery: `bin/celery worker --logfile=/var/log/mediagoblin/celery.log --loglevel=INFO`
- Celery env: MEDIAGOBLIN_CONFIG, CELERY_CONFIG_MODULE=mediagoblin.init.celery.from_celery; paster CELERY_ALWAYS_EAGER=false

## Paths
- Uploads: user_dev/ ; public media user_dev/media/public/ (URL /mgoblin_media/)
- Static: mediagoblin/static/ (URL /mgoblin_static/); theme_static, plugin_static under user_dev/
- Crypto: user_dev/crypto
- nginx client_max_body_size 100m in example
