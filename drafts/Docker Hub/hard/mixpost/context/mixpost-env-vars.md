# Mixpost Lite environment variables

**Source:** https://docs.mixpost.app/lite/configuration/environment-variables (fetched 2026-11-26)

| Group | Variable | Default | Purpose |
|---|---|---|---|
| App | APP_NAME | Mixpost | display name |
| App | APP_KEY | none | encryption key (generator linked) |
| App | APP_DEBUG | false | debug mode; keep off in prod |
| App | APP_DOMAIN | none | domain without protocol (Docker only) |
| App | APP_URL | http://example.com | full app URL |
| DB | DB_HOST | 127.0.0.1 (mysql in Docker) | DB host |
| DB | DB_PORT | 3306 | DB port |
| DB | DB_DATABASE | mixpost_db | DB name |
| DB | DB_USERNAME | mixpost_user | DB user |
| DB | DB_PASSWORD | none | DB password |
| Redis | REDIS_HOST | 127.0.0.1 (redis in Docker) | Redis host |
| Redis | REDIS_PORT | 6379 | Redis port |
| Redis | REDIS_PASSWORD | none | Redis password |
| Storage | MIXPOST_DISK | public | `public` or `s3` |
| S3 | AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY | empty | S3 credentials |
| S3 | AWS_DEFAULT_REGION / AWS_BUCKET | empty | S3 region / bucket |
| Mixpost | MIXPOST_LOG_CHANNEL | none | separate log channel for social connection errors (falls back to LOG_CHANNEL) |
| Mixpost | MIXPOST_AUTH_GUARD | web | dashboard auth guard (not in Docker) |
| Mixpost | MIXPOST_CACHE_PREFIX | mixpost | cache key prefix |
| Mixpost | FFMPEG_PATH | /usr/bin/ffmpeg | ffmpeg binary (not in Docker) |
| Mixpost | FFPROBE_PATH | /usr/bin/ffprobe | ffprobe binary (not in Docker) |
| Logging | LOG_CHANNEL | single | `single` or `daily` |
| SSL | SSL_EMAIL | user@example.com | cert registration email (Docker only) |

- Mail variables: not listed on this page.
