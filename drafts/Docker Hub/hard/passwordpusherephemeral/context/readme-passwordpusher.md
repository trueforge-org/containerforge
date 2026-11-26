# PasswordPusher README (master)

Source URL: https://raw.githubusercontent.com/pglombardo/PasswordPusher/master/README.md (fetched)

- What: open-source web app for one-time links to passwords/notes/files/URLs; expiry by views and/or time; encrypted storage; optional passphrases; audit log; MFA (TOTP); admin dashboard; white-label; 31 languages; JSON API.
- License: Apache 2.0.
- Ruby/Rails version: not stated on page.
- DB: Postgres or SQLite; "database or ephemeral" mode.
- Docker: docker-compose.yml with TLS_DOMAIN (Let's Encrypt), PWPUSH_MASTER_KEY optional; production Dockerfile at containers/docker/Dockerfile.
- Images: pglombardo/pwpush, pglombardo/pwpush-ephemeral, pglombardo/pwpush-public-gateway.
- Port: 5100 app (publish 5100:5100 without TLS_DOMAIN).
- Env vars named: TLS_DOMAIN, PWPUSH_MASTER_KEY, PWP__REQUIRE_MFA=true, SECRET_KEY_BASE (Railway).
- API v2: /api/v2/version, /api/v2/pushes; legacy /p /f /r.
- Docs: docs.pwpush.com; CLI: github.com/pglombardo/pwpush-cli
