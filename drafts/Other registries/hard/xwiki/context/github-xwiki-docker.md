# xwiki/xwiki-docker (18/postgres-tomcat at pinned commit 589e96c, plus README and LICENSE)

## Source URL(s) + date
- https://raw.githubusercontent.com/xwiki/xwiki-docker/589e96c134218b1e1d6dab64865aade428ae1106/18/postgres-tomcat/Dockerfile (fetched 2026-11-27)
- https://raw.githubusercontent.com/xwiki/xwiki-docker/589e96c134218b1e1d6dab64865aade428ae1106/18/postgres-tomcat/xwiki/docker-entrypoint.sh (fetched 2026-11-27)
- https://raw.githubusercontent.com/xwiki/xwiki-docker/master/README.md (fetched 2026-11-27)
- https://raw.githubusercontent.com/xwiki/xwiki-docker/master/LICENSE (fetched 2026-11-27, LGPL-2.1 text)
- https://github.com/xwiki/xwiki-docker/blob/589e96c.../18/postgres-tomcat/Dockerfile: same as raw.

## Dockerfile (pinned 589e96c)
- `FROM tomcat:10-jre25`. Labels: LGPL-2.1, source github xwiki-docker.
- Apt (`--no-install-recommends`): curl unzip procps libxtst6 libxi6 libxinerama1 libdbus-glib-1-2 libcairo2 libcups2 libsm6 libx11-xcb1 libnss3 libxml2-dev libxslt1.1.
- `ENV CURL_OPTIONS="-fSL --retry 5 --retry-all-errors --retry-delay 5 --connect-timeout 30"`.
- LibreOffice 26.2.7 (`LIBREOFFICE_VERSION`), deb tarball from download.documentfoundation.org per arch:
  - amd64 sha256 `8cd04a88396a9230264ff784ec89cc090cbfd0960c192483ba2b80fa53939416`
  - arm64 sha256 `d871da75fe387f9dab5acb7569d46d1098835c25b53695c89152f5194ad34411`
  - installed to `/opt/libreoffice<major>.<minor>`, symlinked `/opt/libreoffice`; build fails unless `/opt/libreoffice/program/soffice` exists.
- XWiki: `XWIKI_VERSION=18.9.0`; WAR from `https://maven.xwiki.org/releases/org/xwiki/platform/xwiki-platform-distribution-war/18.9.0/...war`, sha256 `e15f79ad379cca52cdeb22035c2fd4d04aad8b18acefbe429e770943bde2c823`.
  - `rm -rf /usr/local/tomcat/webapps/*`, unzip WAR to `webapps/ROOT`, `mkdir /usr/local/tomcat/temp`, `/usr/local/xwiki/data`.
- PostgreSQL JDBC 42.7.14 from repo1.maven.org, sha256 `73914527305a40cce504b0d3d90b23caf565136912d607ae8ae7c5895512332c`, to `WEB-INF/lib/`.
- `COPY tomcat/setenv.sh /usr/local/tomcat/bin/`; `COPY xwiki/hibernate.cfg.xml` to `WEB-INF/`.
- logback patch adds file appender to `WEB-INF/classes/logback.xml`.
- `sed` sets distribution id `xwiki-platform-distribution-docker` in `META-INF/extension.xed`.
- `COPY xwiki/docker-entrypoint.sh /usr/local/bin/`.
- `VOLUME /usr/local/xwiki`.
- `ENTRYPOINT ["docker-entrypoint.sh"]`, `CMD ["xwiki"]`.

## Entrypoint (docker-entrypoint.sh)
- Env defaults (file_env, supports `*_FILE`): DB_USER=xwiki, DB_PASSWORD=xwiki, DB_HOST=db, DB_PORT='' (JDBC default 5432), DB_DATABASE=xwiki, JDBC_PARAMS=`?`, CONTEXT_PATH=ROOT.
- Non-ROOT context: copies ROOT webapp to `webapps/$CONTEXT_PATH`.
- Sed-replaces user, password, host(:port), database, JDBC params in `WEB-INF/hibernate.cfg.xml`.
- Sets `environment.permanentDirectory=/usr/local/xwiki/data` in xwiki.properties/xwiki.cfg.
- Restores/saves `hibernate.cfg.xml`, `xwiki.cfg`, `xwiki.properties` between `/usr/local/xwiki/data` and WEB-INF (persist across restarts).
- `mkdir /usr/local/xwiki/data/tmp` and `/usr/local/xwiki/data/logs`; java.io.tmpdir points there (setenv.sh).
- First start marker `.first_start_completed` in the webapp dir; if not writable (read-only rootfs) it reconfigures every start.
- `xwiki` arg: configure then start Tomcat. Other args: `exec "$@"`.

## Ports / volumes / user
- Tomcat HTTP 8080. Volume `/usr/local/xwiki` (permanent dir). Runs as root by default (base image).

## README (master)
- Official image sources; tags released when XWiki version releases.
- Install docs at xwiki.org (403 to fetch, see README of context).

## License
- LGPL-2.1 (LICENSE file confirmed).

## Gotchas
- Database-backed: DB_HOST defaults to `db`; PostgreSQL JDBC driver pinned in Dockerfile.
- LibreOffice is installed for JODConverter at `/opt/libreoffice`; required for office conversion.
