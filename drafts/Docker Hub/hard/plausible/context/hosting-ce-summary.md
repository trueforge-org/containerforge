# plausible/hosting (Community Edition Docker setup, as served)

Source URL: https://raw.githubusercontent.com/plausible/hosting/master/README.md (fetched). Content describes CE repo tag v3.2.2.

- Clone: `git clone -b v3.2.2 --single-branch https://github.com/plausible/community-edition plausible-ce`
- Files: compose.yml, clickhouse/, LICENSE, README.md; user-created compose.override.yml (ports) and .env
- Prereqs: Docker + Compose; CPU with SSE 4.2 or NEON (ClickHouse); >= 2 GB RAM recommended
- .env: BASE_URL (public domain, DNS needed for Let's Encrypt; local http://localhost:8000); SECRET_KEY_BASE (`openssl rand -base64 48`, >=64 bytes); HTTP_PORT=80; HTTPS_PORT=443 (both enable auto TLS)
- Ports: public 80:80, 443:443 (override file, plausible service); local eval 8000:80 with BASE_URL=http://localhost:8000 and HTTP_PORT=80
- Steps: create .env; add ports override; `docker compose up -d`; open $BASE_URL; create first user
- Upgrade/config/integrations: wiki github.com/plausible/community-edition/wiki
- Support: GitHub discussions (self-hosted-support); release announcements in plausible/analytics releases.
- Not stated on page: DB versions, DATABASE_URL/CLICKHOUSE_DATABASE_URL formats, MAILER_*, volumes.
