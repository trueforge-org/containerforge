# adminer.org (project website)

**Source URL(s):** https://www.adminer.org/
**Fetched:** 2026-11-26

## What it is
- A database management tool delivered as a single PHP file. Lighter alternative to phpMyAdmin (which the site says is thousands of files). Latest version listed: 6.3.1.
- Development priorities in order: security, user experience, performance, feature set, size.

## Supported databases
- Built in: MySQL, MariaDB, PostgreSQL, SQLite, MS SQL, Oracle (CockroachDB also listed).
- Via plugins: Elasticsearch, SimpleDB, MongoDB, Redis, Firebird, ClickHouse, IGDB, IMAP, DuckDB, Parquet.

## Install and running
- Upload the PHP file to a web server. Re-upload is easy if deleted.
- Docker example on the site: `docker run -p 8080:8080 adminer`.
- Desktop builds bundle PHP for Windows, macOS (Apple Silicon) and Linux; not relevant to containers.
- Variants: MySQL-only and English-only smaller files.
- Latest stable file: `https://www.adminer.org/latest[-mysql][-en].php`.

## Runtime deps
- PHP 5.4+, 7 and 8, with sessions enabled.

## Env vars / Ports / Volumes
- Site documents none. Docker-specific details are in the Docker Hub summary (docker-adminer `dockerhub-adminer.md`).

## Config and extensibility
- Designs: CSS themes such as `adminer.css` or `adminer-dark.css` placed alongside `adminer.php`.
- Plugins: a plugins page lists database drivers and security plugins (for example OTP). Login behavior can be customized through extensions.

## Security recommendations
- Adminer refuses connections without a password and rate-limits connection attempts.
- Limit public access: IP allowlisting, web-server password protection, security plugins, custom `login` method.
- Delete the file when not needed. Update on each new version (past security bugs).

## License
Free for commercial and non-commercial use under the Apache License or GPL 2.
