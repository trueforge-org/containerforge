# GitHub: docker-library/redmine 6.1/bookworm (Dockerfile, docker-entrypoint.sh)

Source URL(s):
- https://raw.githubusercontent.com/docker-library/redmine/49a27f29f1d214a4226af75b55578e36d3474c4c/6.1/bookworm/Dockerfile
- https://raw.githubusercontent.com/docker-library/redmine/49a27f29f1d214a4226af75b55578e36d3474c4c/6.1/bookworm/docker-entrypoint.sh
Fetched: 2026-11-27 (generated file: "apply-templates.sh"; do not edit directly)

## Dockerfile
| Item | Value |
| --- | --- |
| base | ruby:3.4-slim-bookworm |
| user | group/user `redmine` uid/gid 999 |
| apt | bzr, ca-certificates, ghostscript, git, gsfonts, imagemagick, mercurial, openssh-client, subversion, tini, wget |
| ImageMagick | policy.xml edited to allow PDF read (ghostscript thumbnails) |
| gosu | GOSU_VERSION 1.19 from github tianon/gosu, GPG verified (key B42F6819007F00F88E364FD4036A9C25BF357DD4) |
| ENV | RAILS_ENV=production, HOME=/home/redmine, RAILS_LOG_TO_STDOUT=true |
| WORKDIR | /usr/src/redmine |
| version | REDMINE_VERSION 6.1.6; REDMINE_DOWNLOAD_URL https://www.redmine.org/releases/redmine-6.1.6.tar.gz; REDMINE_DOWNLOAD_SHA256 a09f0541e3ef5579de8be1c21fc9cabbd7625d77ec4dd2ddddc39ad9c2c5a483 |
| dirs | config, db, log, public/assets, sqlite, tmp, tmp/pdf, tmp/pids (chown redmine, mode 1777 for dirs) |
| build deps | default-libmysqlclient-dev, freetds-dev, gcc, libpq-dev, libsqlite3-dev, libxml2-dev, libxslt-dev, libyaml-dev, make, patch, pkgconf, xz-utils (removed after bundle install) |
| bundler | `bundle config --local without 'development test'`; puma added to Gemfile top-level |
| VOLUME | /usr/src/redmine/files |
| EXPOSE | 3000 |
| ENTRYPOINT | ["/docker-entrypoint.sh"] |
| CMD | ["rails", "server", "-b", "0.0.0.0"] |

## docker-entrypoint.sh
- Runs `_fix_permissions` (chown/chmod on config, log, public/*assets, tmp, files) when started as root, then `exec gosu redmine`.
- If no `config/database.yml`, builds it from env:
  - `REDMINE_DB_MYSQL` (adapter mysql2, port 3306), `REDMINE_DB_POSTGRES` (postgresql, port 5432), `REDMINE_DB_SQLSERVER` (sqlserver, port 1433); each uses `*_FILE` secret variant via file_env.
  - Vars: REDMINE_DB_PORT, REDMINE_DB_USERNAME, REDMINE_DB_PASSWORD, REDMINE_DB_DATABASE, REDMINE_DB_ENCODING (utf8 for postgres).
  - No DB env set: falls back to sqlite3.
- Also documented in script: REDMINE_SECRET_KEY_BASE, REDMINE_NO_DB_MIGRATE, REDMINE_PLUGINS_MIGRATE (names found in file).

## Gotchas
- Dockerfile is generated; do not edit directly.
- Image runs gosu step-down when started as root; with `--user` it runs directly.
- Tag and Dockerfile version differ (see dockerhub-redmine.md): this file is 6.1.6 at commit 49a27f2.
