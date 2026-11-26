# Docker Hub: openspeedtest/latest

Source URL(s): https://hub.docker.com/r/openspeedtest/latest · fetched 2026-11-26

- Description: HTML5 speed test; base nginxinc/nginx-unprivileged:stable-alpine; non-root; static files only.
- License: MIT. Categories: Image, Networking.
- Tags: `latest` only; updated 6 days before fetch; digest sha256:ba63bc83…; 108.1 MB; 50M+ pulls.
- Architectures: not listed.
- Run: `docker run --restart=unless-stopped --name openspeedtest -d -p 3000:3000 -p 3001:3001 openspeedtest/latest`.
- LE: ENABLE_LETSENCRYPT=True, DOMAIN_NAME, email var; `-p 80:3000 -p 443:3001`.
- Custom cert: `-v /path:/etc/ssl/` with nginx.crt and nginx.key.
- Advanced env: CHANGE_CONTAINER_PORTS, HTTP_PORT, HTTPS_PORT, SET_USER=101, ALLOW_ONLY, SET_SERVER_NAME.
