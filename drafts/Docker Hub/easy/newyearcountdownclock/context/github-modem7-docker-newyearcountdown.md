# modem7/Docker-NewYearCountdown

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/modem7/Docker-NewYearCountdown/master/README.md
- https://raw.githubusercontent.com/modem7/Docker-NewYearCountdown/393458057f1380dd0f83bed447c6ac740e342a08/Dockerfile (pinned HEAD named in plan.md)
- https://raw.githubusercontent.com/modem7/Docker-NewYearCountdown/393458057f1380dd0f83bed447c6ac740e342a08/conf/nginx-site.conf
- https://github.com/modem7/Docker-NewYearCountdown/releases
- Fetched 2026-11-26. The draft's commit `a1c6bede...` was not fetched; plan.md says the diff touches only `.gitattributes` and `.github/workflows/`.

**What it is**
- A self-hosted countdown page to the next New Year, packaged as a static HTML/JS site served by nginx. Packaged by modem7; original creator patrickgold (https://github.com/patrickgold/newyear-countdown). License MIT.
- Live demo: https://modem7.github.io/Docker-NewYearCountdown/

**Install/build steps and build deps**
- Upstream Dockerfile (pinned `393458057...`):
  ```
  FROM nginxinc/nginx-unprivileged:1.31.7-alpine
  ARG UID=101
  ARG GID=101
  COPY --chown=$UID:0 --chmod=755 src/ /usr/share/nginx/html/
  COPY --chown=$UID:0 --chmod=644 conf/nginx-site.conf /etc/nginx/conf.d/default.conf
  EXPOSE 8080
  HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=10s \
      CMD ["sh", "-c", "curl -fSs 127.0.0.1:8080/healthz || exit 1"]
  STOPSIGNAL SIGQUIT
  USER $UID
  CMD ["nginx", "-g", "daemon off;"]
  ```
- No RUN instructions upstream. Build deps: none. Build is a copy of static files.
- Base is alpine (musl) upstream; this is an upstream build detail only, the ContainerForge build uses the nginx base.

**Runtime deps**
- nginx (upstream base `nginxinc/nginx-unprivileged`). Upstream healthcheck uses `curl`.

**Binaries/entrypoint/CLI flags**
- `nginx -g "daemon off;"` (upstream CMD). No app binary.

**Env vars**
- None. README: "no configuration needed". The countdown targets the next January 1st using the "local system time" (README wording; the browser performs the calculation per plan, not verified here).

**Ports**
- 8080/tcp (`listen 8080;`).

**Volumes/paths and persistent data**
- None documented. Content root is `/usr/share/nginx/html` (copied from upstream `src/`).

**User/UID & permissions**
- Upstream `USER $UID` with UID 101 (GID 101 ARG); copied files are owned `101:0`, mode 755 (src) and 644 (conf).

**Config files and formats**
- `conf/nginx-site.conf` (full content below), installed to `/etc/nginx/conf.d/default.conf` upstream:
  - `listen 8080;`, `root /usr/share/nginx/html;`, `index index.html;`, `server_name _;`, `error_page 404 /index.html;`
  - Headers (`always`): `X-Content-Type-Options nosniff`, `X-Frame-Options DENY`, `Referrer-Policy no-referrer`, `Content-Security-Policy "default-src 'self'; img-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'"`.
  - gzip: `on`, `gzip_vary on`, `gzip_proxied any`, `gzip_comp_level 6`, `gzip_min_length 256`, types `text/plain text/css application/javascript application/json image/svg+xml`.
  - `location /healthz { return 200; }`
  - `location / { try_files $uri $uri/ =404; }`
  - `location ~* \.(jpg|jpeg|gif|png|css|js|ico|webp|tiff|ttf|svg|mp4)$ { expires 5d; }`

**Healthcheck/readiness endpoints**
- `GET /healthz` returns 200 (nginx `return 200`). Upstream HEALTHCHECK curls `127.0.0.1:8080/healthz`.

**Version/release info and asset naming**
- Releases page: "There aren't any releases here." No release assets. Tags page not readable from the fetch.
- Docker Hub lists only `latest` (see Docker Hub summary).

**Arch support**
- Docker Hub lists amd64, arm/v6, arm/v7, arm64/v8 (upstream build). Static content, arch-independent.

**CI/build**
- GitHub Actions `.github/workflows/test.yml` (page structure, gzip, headers, static assets, non-root, no sudo, no world-writable files, Playwright rollover check). Multi-arch build and Docker Hub push via `.woodpecker.yml` on push to `master`.

**Gotchas**
- CSP allows `'unsafe-inline'` for script and style; keep as upstream unless the page breaks.
- Upstream `STOPSIGNAL SIGQUIT` (nginx graceful stop); not in plan.md.
- The image is designed for port 8080 with no env; it has no config directory of its own (ContainerForge adds `/config` via the nginx base).
- Plan check: the Dockerfile, port, healthz, CSP, gzip and UID 101 claims match the source. The plan's "meta refresh" claim for `index.html` was not verified (page not fetched).
