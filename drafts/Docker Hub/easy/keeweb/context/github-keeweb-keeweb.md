# keeweb/keeweb (GitHub)

Source URL(s) + fetch date:
- https://github.com/keeweb/keeweb (repo page)
- https://github.com/keeweb/keeweb/releases and https://github.com/keeweb/keeweb/releases/latest
- https://raw.githubusercontent.com/keeweb/keeweb/v1.18.7/package/docker/Dockerfile (blob link in draft/plan)
- https://raw.githubusercontent.com/keeweb/keeweb/v1.18.7/LICENSE
- https://raw.githubusercontent.com/keeweb/keeweb/v1.18.7/README.md
- Release asset URLs (direct downloads, not fetched): `https://github.com/keeweb/keeweb/releases/download/v<V>/KeeWeb-<V>.html.zip`, `.../Verify.sha256`, `.../KeeWeb-<V>.linux.x64.deb`, `.../KeeWeb-<V>.win.arm64.zip`
- Fetched 2026-11-26

## What it is
KeeWeb: free cross-platform password manager compatible with KeePass databases. Runs in a browser or as a desktop app (Electron). No server required. Self-hosting needs only a static file server; the app is one HTML file plus an optional service worker for offline use.

## Install/build steps (upstream package/docker/Dockerfile, v1.18.7, verbatim logic)
- Header comments: build with `docker build -t keeweb .`; run example `docker run --name keeweb -d -p 443:443 -p 80:80 -e 'DH_SIZE=512' -v $EXT_DIR:/etc/nginx/external/ keeweb`; `DH_SIZE=512` generates a self-signed cert when no certs are provided.
- `FROM nginx:stable`, `LABEL maintainer="antelle.net@gmail.com"`.
- `RUN apt-get -y update && apt-get -y install openssl curl unzip && rm -rf /var/lib/apt/lists/*`
- `RUN rm -rf /etc/nginx/conf.d/*; mkdir -p /etc/nginx/external`
- `RUN sed -i` edits to `/etc/nginx/nginx.conf`: access_log to /dev/stdout, error_log to /dev/stdout info, `daemon off;` inserted before `pid`.
- `COPY keeweb.conf /etc/nginx/conf.d/keeweb.conf`; `COPY entrypoint.sh /opt/entrypoint.sh` (chmod a+x); `COPY dist keeweb`.
- Plugins: `curl -O https://github.com/keeweb/keeweb-plugins/archive/master.zip`, unzip, `mv keeweb-plugins-master/docs keeweb/plugins`, cleanup.
- `RUN apt-get -y remove curl unzip`
- `ENTRYPOINT ["/opt/entrypoint.sh"]`, `CMD ["nginx"]`, `EXPOSE 443`, `EXPOSE 80`.
- No ENV, ARG, VOLUME, USER declared. Container runs as the nginx base default user.
- Build tooling (from README): `grunt` builds HTML into `dist/`; `grunt desktop` for desktop (macOS, needs wine per fetch); dev `grunt dev` serves `http://localhost:8085`; `npm run electron`.

## Runtime deps
- nginx (base). Upstream also installs openssl, curl and unzip at build time (removes curl and unzip after plugin fetch; openssl stays).

## Binaries/entrypoint/CLI flags
- Upstream entrypoint: `/opt/entrypoint.sh` (not fetched; the upstream comments mention cert files and `DH_SIZE`). `CMD nginx`.
- Config file `keeweb.conf` copied to `/etc/nginx/conf.d/` (not fetched).

## Env vars
- None declared in Dockerfile. README/Docker docs mention `DH_SIZE=512` (self-signed cert generation, read by upstream entrypoint).

## Ports
- 80 (HTTP) and 443 (HTTPS), per EXPOSE and README docker run.

## Volumes/paths and persistent data
- Certificates: `/etc/nginx/external/` (expects `dh.pem`, `cert.pem`, `key.pem`). Bind mount of host dir recommended (no VOLUME in Dockerfile).
- App files: `keeweb/` (dist) under the image root (`COPY dist keeweb`).

## User/UID & permissions
- No USER. Runs as nginx base default (root in nginx:stable).

## Config files and formats
- `keeweb.conf` (nginx server block, not fetched). Upstream does not document a config.json; README does not mention config options or plugin configuration.

## Healthcheck/readiness endpoints
None documented.

## Version/release info and asset naming
- Releases page (fetched): `v1.18.9` (08 May, year not shown) Pre-release, 7 assets; `v1.18.8` (30 Apr) Pre-release, 2 assets; `v1.18.7` (18 Jul; asset timestamps show 2021) marked **Latest**, title "Desktop apps v1.18.7", 18 assets; `v1.18.6` (19 May) ... older. `v1.19.0` not on the first page.
- v1.18.7 assets (partially listed): `KeeWeb-1.18.7.html.zip`, `KeeWeb-1.18.7.linux.AppImage`, `KeeWeb-1.18.7.linux.snap`, `KeeWeb-1.18.7.linux.x64.deb`, `KeeWeb-1.18.7.linux.x64.zip`, `KeeWeb-1.18.7.linux.x86_64.rpm`, `KeeWeb-1.18.7.mac.arm64.dmg`, `KeeWeb-1.18.7.mac.x64.dmg`, `KeeWeb-1.18.7.win.arm64.exe`, `KeeWeb-1.18.7.win.arm64.zip`, plus source zip/tar.gz. Upstream `Verify.sha256` (listed in the draft/plan, not on this page's visible list).
- Asset naming: `KeeWeb-<V>.html.zip` (web build), `KeeWeb-<V>.linux.x64.deb`, `KeeWeb-<V>.linux.AppImage`, `KeeWeb-<V>.win.arm64.zip`, `KeeWeb-<V>.mac.*.dmg`.
- Repo default branch README (fetched via repo page summary) refers to Docker image tags for version `1.19.0`. Not confirmed on the releases page; UNVERIFIED.

## Arch support
Web build (`.html.zip`) is architecture independent. Desktop assets are per platform.

## License
MIT License. LICENSE at v1.18.7: "MIT License", "Copyright (c) 2021 Antelle https://antelle.net". Standard MIT text.

## Gotchas
- Upstream Docker image is an nginx-based image with `openssl curl unzip` installed then curl/unzip removed.
- Upstream expects TLS certs in `/etc/nginx/external`; plan serves plain HTTP on 8080 and leaves TLS to a reverse proxy.
- Web Crypto/HTTPS requirement is not stated in README (per fetch); plan's caveat is general browser behaviour, not from this source.
- Upstream web build: README says the app is "a single HTML file + a service worker" for self-hosting.
- Dropbox support in self-hosted setups requires extra config (wiki link; not fetched).

## Contradictions with plan.md
- plan.md section 1 says `v1.18.8` has no assets. Releases page summary shows 2 assets for v1.18.8 (names not listed). UNVERIFIED which is correct.
- plan.md section 1 says `v1.18.8` and `v1.18.9` are "(2026-05)". Releases page shows 30 Apr and 08 May with the year not shown. Not confirmable from the year.
- plan.md section 1 says Renovate stays on 1.18.7 because prereleases are skipped. Consistent with the releases page (1.18.7 is marked Latest).
