# hub.docker.com/r/m1k1o/blog

Source: https://hub.docker.com/r/m1k1o/blog (fetched 2026-11-26)

- Description: lightweight self-hosted facebook-style PHP blog, single user
- Publisher m1k1o; 50K+ pulls; image ~201.8 MB; updated ~1 day before fetch
- Tags shown: `latest` only (digest sha256:30229ce39...)
- Quick start: `docker run -d -p 80:80 -v $PWD/data:/var/www/html/data m1k1o/blog:latest`
- Env: BLOG_ prefixed keys mirror config.ini (TITLE, NAME, NICK, PASS, LANG, FRIENDS as multiline user:pass); TZ
- Compose vars: HTTP_PORT, DATA
- Permissions: chown 33:33 ./data/
- Manual install: Apache 2.0, PHP 7.4, MariaDB 10.1 or SQLite 3 (conflicts with README PHP 8.0+)
- Architectures: not stated

## Docker Hub JSON (added 2026-11-26)
- Source: https://hub.docker.com/v2/repositories/m1k1o/blog/ and /tags?page_size=10
- pull_count 90377; star_count 1; last_updated 2026-11-25T19:13:46Z; description "Lightweight self-hosted facebook-styled PHP blog. Plug & Play docker container."
- Tags (9): latest (2026-11-25, 211.6 MB), 1, 1.5, 1.5.1 (2026-11-25) all linux/amd64, linux/arm64, linux/arm/v7
- 1.5.0 (2026-10-23, 196.1 MB) linux/amd64, linux/arm64, linux/arm/v7
- 1.4, 1.4.1 (2023-02-04) multi-arch + unknown/unknown; v1.3, v1.2 (2020) linux/amd64 only
- Confirms 1.5.1 is published on Docker Hub (plan pins 1.5.0)
