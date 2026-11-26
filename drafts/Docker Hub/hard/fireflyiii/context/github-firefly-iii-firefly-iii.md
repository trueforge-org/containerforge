# firefly-iii/firefly-iii

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/firefly-iii/firefly-iii/v6.7.9/.env.example (fetched 2026-11-26; the fetch tool returned a summary, not verbatim text)
- https://github.com/firefly-iii/firefly-iii/releases/download/v6.7.9/FireflyIII-v6.7.9.tar.gz.sha256 (fetched via its CDN redirect, 2026-11-26)
- https://raw.githubusercontent.com/firefly-iii/firefly-iii/v6.7.9/README.md (404)
- https://raw.githubusercontent.com/firefly-iii/firefly-iii/main/README.md (404)
- Release tarball (not downloaded, binary archive): https://github.com/firefly-iii/firefly-iii/releases/download/v${VERSION}/FireflyIII-v${VERSION}.tar.gz
- Repo page: https://github.com/firefly-iii/firefly-iii (referenced; the plan records GitHub "Latest" = v6.7.9)

## What it is

Firefly III: self-hosted personal finance manager (Laravel/PHP). Budgets, categories, tags, imports, reports. Official Docker image `fireflyiii/core` is built from a separate Azure DevOps repo (see failures in README).

## Install/build steps

- Release tarball is a prebuilt Laravel app with vendor dir (arch independent). Plan: extract to `/app/www`, verify `artisan` and `public/index.php` exist.
- Checksum file format (verified this fetch): one line, `f905729c3be6e66d5333c22992281224ef1dc7e21cea13f4ef09af643d09b825 *FireflyIII-v6.7.9.tar.gz`. A `sha256sum`-style line; the hash is the first field (`cut -d' ' -f1` extracts it).
- GitHub digest of the v6.7.9 tar.gz per plan: `sha256:f905729c3be6e66d5333c22992281224ef1dc7e21cea13f4ef09af643d09b825` (matches the checksum file).
- Archive layout (flat vs top-level dir): not verified (tarball not fetched).

## Runtime deps

- PHP per composer.json (plan): `php >= 8.5` with extensions bcmath, curl, fileinfo, iconv, intl, json, mbstring, openssl, pdo, session, simplexml, tokenizer, xml, xmlwriter. Not re-verified here (composer.json not fetched).

## Env vars (from `.env.example` at v6.7.9, summarized by the fetch tool)

Not verbatim; the fetch returned a paraphrase. Key names and defaults as summarized:

| Name | Default in example | Notes |
| --- | --- | --- |
| `APP_ENV` | `production` | do not use `testing` |
| `APP_DEBUG` | `false` | |
| `APP_KEY` | placeholder | 32 characters, avoid special characters; `_FILE` variant exists |
| `APP_URL` | `http://localhost` | must match external URL |
| `SITE_OWNER` | email | `_FILE` variant |
| `TZ` | `Europe/Amsterdam` | |
| `TRUSTED_PROXIES` | empty | `**` helps behind reverse proxies |
| `DEFAULT_LANGUAGE` | `en_US` | |
| `DEFAULT_LOCALE` | `equal` | |
| `LOG_CHANNEL` | `stack` | daily files and stdout |
| `APP_LOG_LEVEL` | `notice` | |
| `AUDIT_LOG_LEVEL` | `emergency` | info enables audit log |
| `DB_CONNECTION` | `mysql` | pgsql/sqlite supported per plan |
| `DB_HOST` | `db` | |
| `DB_PORT` | `3306` | |
| `DB_DATABASE` | `firefly` | |
| `DB_USERNAME` | `firefly` | |
| `DB_PASSWORD` | placeholder | |
| `DB_SOCKET` | empty | |
| `MYSQL_USE_SSL` | `false` | plus `MYSQL_SSL_*` vars |
| `PGSQL_SSL_MODE` | `prefer` | plus `PGSQL_SSL_*` vars; `PGSQL_SCHEMA=public` |
| `CACHE_STORE` | `file` | |
| `SESSION_DRIVER` | `file` | |
| `REDIS_SCHEME` | `tcp` | |
| `REDIS_HOST` | `127.0.0.1` | |
| `REDIS_PORT` | `6379` | |
| `REDIS_PASSWORD` | empty | |
| `REDIS_DB` | `0` | |
| `REDIS_CACHE_DB` | `1` | |
| `COOKIE_PATH` | `/` | `COOKIE_SECURE=false`, `COOKIE_SAMESITE=lax` |
| `MAIL_MAILER` | `log` | SMTP `MAIL_HOST`, `MAIL_PORT` (2525 example), `MAIL_FROM`, `MAIL_USERNAME`, `MAIL_PASSWORD`, `MAIL_ENCRYPTION` |
| `AUTHENTICATION_GUARD` | `web` | alt `remote_user_guard`; LDAP no longer supported |
| `AUTHENTICATION_GUARD_HEADER` | `REMOTE_USER` | |
| `PASSPORT_PRIVATE_KEY` / `PASSPORT_PUBLIC_KEY` | empty | `_FILE` variants |
| `DISABLE_FRAME_HEADER`, `DISABLE_CSP_HEADER` | `false` | |
| `STATIC_CRON_TOKEN` | placeholder | 32 characters |
| `DKR_CHECK_SQLITE` | `true` | |
| `CACHE_PREFIX` | `firefly` | |
| `QUEUE_DRIVER` | `sync` | |

## Ports

- Not in `.env.example`. Upstream image port 8080 (draft; chart `targetPort: 8080`).

## Volumes/paths

- Chart mounts `/var/www/html/storage/upload` (draft). Laravel storage is `storage/` (app, build, database, debugbar, export, framework, logs, upload) and `bootstrap/cache` (plan).

## Cron

- Artisan command `firefly-iii:cron` (per plan). Chart cron schedule `0 3 * * *` (daily at 03:00) is the only cadence evidence here; upstream docs not reachable (see README failures).

## Healthcheck

- Chart probes (liveness, readiness, startup) use `GET /healthcheck` (not `/`). Plan's container test uses `/`; see gotchas.

## Version/release info

- Plan: `v6.7.9` published 2026-10-11, GitHub Latest. Draft `6.2.21` is older (the chart still pins 6.2.21).

## Arch support

- Tarball is arch independent. Official image is multi-arch (per Hub page, built from Azure DevOps).

## License

- AGPL v3 (per Hub page; plan says GitHub API `AGPL-3.0`). Plan bake `AGPL-3.0-only` remains unverified vs or-later.

## Gotchas

- Plan says Valkey is optional and the draft calls it hard; the chart enables valkey and sets Redis as cache/session driver, while the upstream example defaults to `file`.
- Chart's probe path `/healthcheck` could be used in container-test.yaml instead of `/` (plan leaves `/`). Not verified that `/healthcheck` exists in the tarball.

## Contradictions with plan.md

- Plan section 1 said the `.sha256` format is UNVERIFIED; now verified (see above). Plan edited.
