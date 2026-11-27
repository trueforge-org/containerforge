# GitHub: tracksapp/tracks (commit 8dcca98c)

Source URL(s): https://raw.githubusercontent.com/tracksapp/tracks/8dcca98c6c48404d8328bbee220a8b19d48799ce/Dockerfile , .../docker-entrypoint.sh (fetched 2026-11-27)

## Dockerfile
- ARG RUBY_VERSION=3.3; stages: base (`ruby:${RUBY_VERSION}`), precompile, production, test, development.
- base: WORKDIR /app; touch /etc/app-env; apt `npm netcat-openbsd`; `npm install -g yarn`; `gem install bundler`; mkdir /app/log.
- COPY config (database.docker.yml -> database.yml, site.docker.yml -> site.yml), bin, script, public, vendor, lib, app, db, Rakefile, config.ru, .yardopts, COPYING, docker-entrypoint.sh, Gemfile*, .git (glob).
- ENTRYPOINT `["/app/docker-entrypoint.sh"]`; EXPOSE 3000; CMD `["./bin/rails","server","-b","0.0.0.0"]`.
- precompile: `bundle config set deployment true`; `bundle install --jobs 4`; `RAILS_GROUPS=assets bundle exec rake assets:precompile`.
- production: `bundle config set without assets`; frozen 1; bundle install; copies /app/public/assets from precompile.
- test: adds test/ and doc/; development: with development test.
- No USER directive (runs as root).

## docker-entrypoint.sh (bash)
| var | default |
| --- | --- |
| RAILS_ENV | production |
| DATABASE_NAME | tracks |
| DATABASE_HOST | db |
| DATABASE_PORT | 3306 |
| DATABASE_USERNAME | tracks |
| DATABASE_PASSWORD | password (empty if DATABASE_PASSWORD_EMPTY=1) |
| DATABASE_TYPE | mysql2 |
| DATABASE_ENCODING | utf8 |
- Sets RAILS_SERVE_STATIC_FILES=TRUE and RAILS_LOG_TO_STDOUT=TRUE; then `exec "$@"`.

## Ports
- 3000/tcp

## Config files
- config/database.docker.yml and config/site.docker.yml baked into image.

## Runtime deps
- Ruby 3.3 base, Node/npm + yarn, netcat-openbsd, bundler gems (Gemfile.lock).

## Gotchas
- Default DATABASE_HOST is `db` (compose service name); chart sets 10.0.0.10.
- Rails default DB is MySQL/MariaDB (mysql2); no SQLite default in these files.
