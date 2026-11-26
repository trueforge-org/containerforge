# owncast server setup (docs)

**Source URL(s) + fetch date**
- https://owncast.online/docs/configuration/server-setup/ (fetched 2026-11-26)

**Facts**
- No default admin password is stated. Password rules: 8 to 192 characters, lowercase, uppercase, a digit, and one of `!@#$%^&*`, no dash. Lost password is reset with `--adminpassword` at startup.
- No default stream key is stated. Admin UI pre-fills a 30-character auto-generated key for new keys. Custom keys: 8 to 192 characters, lowercase, uppercase, digit, no dash.
- Web server default port `8080`; restart needed to change.
- RTMP default port `1935`; restart needed to change.
- RTMP address default `0.0.0.0` (all interfaces); restart needed to change.
- FFmpeg path setting is an absolute file path; the page gives no default lookup behaviour.
- Data directory: not covered.
- Reverse proxy: no guidance on this page. Related: "Websocket host override" (CDN origin URL) and "Serving Endpoint" (optional full URL for video content). SSL/proxy page `/docs/sslproxies/` is linked but not fetched.
- No environment variables mentioned.
