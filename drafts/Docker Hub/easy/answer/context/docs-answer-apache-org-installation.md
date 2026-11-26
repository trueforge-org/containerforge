# answer.apache.org: installation and environment variables

**Source URL(s) + fetch date**
- https://answer.apache.org/docs/installation (fetched 2026-11-26)
- https://answer.apache.org/docs/env (fetched 2026-11-26)

**Install methods (docs/installation)**
- Docker Compose: `curl -fsSL https://raw.githubusercontent.com/apache/answer/main/docker-compose.yaml | docker compose -p answer -f - up`. Default port 9080.
- Docker: `docker run -d -p 9080:80 -v answer-data:/data --name answer apache/answer:latest`. Continue at `http://localhost:9080/install`. Images on Docker Hub; `latest` is the latest stable.
- Binary (Go project; download from GitHub releases): `INSTALL_PORT=80 ./answer init -C ./answer-data/`, open `http://localhost:80/install`, finish the wizard, then `./answer run -C ./answer-data/`. `INSTALL_PORT` default 80; `-C` sets the data directory.
- aaPanel: one-click, auto-initialises (wizard skipped). Form port default 9080.

**Install wizard**
1. Choose language. 2. Configure database (MySQL, PostgreSQL, SQLite; SQLite recommended for a first trial). 3. Create config file (click Next; no path given). 4. Basic info (site and admin). 5. Done.

**First-run requirements**
- Site URL must be the browser address; for a subdirectory include the subdirectory.
- Admin email is the login.

**Env vars (docs/env)**
- Table of install and runtime variables, required/optional notes, and length limits as summarised in github-apache-answer.md.
- `AUTO_INSTALL`: "Set to `true` to install from env vars; leaving it unset turns auto-install off."
- `INSTALL_PORT` applies only during installation; after init the page's example starts the site with `SITE_ADDR` matching the port in `SITE_URL`.

**Gotchas**
- Docs say `AUTO_INSTALL` should be `true`. plan.md says any non-empty value (including `false`) enables it; that was not verifiable from these pages.
