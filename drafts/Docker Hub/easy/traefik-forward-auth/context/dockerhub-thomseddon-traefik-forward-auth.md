# thomseddon/traefik-forward-auth (Docker Hub image)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/thomseddon/traefik-forward-auth (fetched 2026-11-26)

**What it is**
"Minimal forward authentication that provides Google oauth login + auth for traefik reverse proxy." About 50M+ pulls and 40 stars. Image about 6.9 MB.

**Tags**
- Only `latest` shown, last updated "over 5 years ago" (no exact date).
- The overview recommends the `2` tag; incremental releases on Docker Hub and GitHub.
- TrueCharts values pin `thomseddon/traefik-forward-auth:latest@sha256:b364aa6a4117569163eff793999901f9f5a0c4f7f2da18b4ecbcd140d7b6107b`.

**Arch support**
Not in a table. ARM builds use tag suffixes `-arm` and `-arm64` (e.g. `2-arm`, `2.1-arm64`).

**Ports**
4181 by default (`PORT`).

**Env vars (compose example and overview)**
`PROVIDERS_GOOGLE_CLIENT_ID`, `PROVIDERS_GOOGLE_CLIENT_SECRET`, `SECRET` (required, signs cookies), `INSECURE_COOKIE` (no HTTPS only). Also `LOG_LEVEL`, `AUTH_HOST`, `COOKIE_DOMAIN`, `COOKIE_NAME`, `DOMAIN`, `WHITELIST`, `LIFETIME`, `URL_PATH`, `DEFAULT_PROVIDER`, plus OIDC and generic OAuth2 provider variables.

**Compose example (simplified)**
```yaml
traefik-forward-auth:
  image: thomseddon/traefik-forward-auth:2
  environment:
    - PROVIDERS_GOOGLE_CLIENT_ID=your-client-id
    - PROVIDERS_GOOGLE_CLIENT_SECRET=your-client-secret
    - SECRET=something-random
    - INSECURE_COOKIE=true
  labels:
    - "traefik.http.middlewares.traefik-forward-auth.forwardauth.address=http://traefik-forward-auth:4181"
    - "traefik.http.middlewares.traefik-forward-auth.forwardauth.authResponseHeaders=X-Forwarded-User"
    - "traefik.http.services.traefik-forward-auth.loadbalancer.server.port=4181"
```

**Notes**
- Callback default `/_oauth`. In overlay mode, requests to it are intercepted.
- Config precedence: flags, then env, then INI file.
- The page says the image was last updated over 5 years ago; check GitHub releases for newer builds.
- Pull command: `docker pull thomseddon/traefik-forward-auth`. No `docker run` example.

**Gotchas**
- Page says the image is stale. The version pinned in plan.md is v2.3.0 from GitHub, which is newer than the Hub image's last update per this page (tag-level versions not confirmed on the page).
