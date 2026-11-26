# misskey .config/example.yml (deployment keys)

**Source:** https://raw.githubusercontent.com/misskey-dev/misskey/master/.config/example.yml (fetched 2026-11-26; master branch)

## Core
- `url`: `https://example.tld/` (final public URL; do not change after start)
- `port`: 3000 (app listen port); optional `socket` (UNIX socket) and `chmodSocket`
- `id`: `'aidx'` (do not change after first start)
- `setupPassword`: commented out (initial admin setup)

## Database (`db`)
- host localhost, port 5432, db misskey, user `example-misskey-user`, pass `example-misskey-pass`
- Optional commented: `disableCache`, `extra` (e.g. `ssl: true`)
- `dbReplications: false`; `dbSlaves` commented

## Redis (`redis`)
- host localhost, port 6379
- Optional commented: family, pass, prefix, db, username
- Separate optional blocks (commented): redisForPubsub, redisForJobQueue, redisForTimelines, redisForReactions

## Reverse proxy
- HTTPS needs reverse proxy (example nginx) on 443 -> Misskey 3000
- `trustProxy` commented; default trusts loopback and private ranges

## Other
- `fulltextSearch.provider`: sqlLike (active); alternatives sqlPgroonga, meilisearch
- `maxFileSize`: 262144000 bytes default; `enableIpRateLimit` default true
- `proxyBypassHosts` active (DeepL, reCAPTCHA, hCaptcha, Cloudflare)
- When `proxy` set, private-address checks are skipped; proxy must block internal networks
- No env-var overrides and no Docker notes in this file.
