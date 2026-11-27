# GOAN wrapper Dockerfile + start.sh (xavier-hernandez, pinned commit)

## Source URL(s) + date

- https://raw.githubusercontent.com/xavier-hernandez/goaccess-for-nginxproxymanager/6044a67020e04752f962a76f95ff99f6cdb00701/Dockerfile
- https://raw.githubusercontent.com/xavier-hernandez/goaccess-for-nginxproxymanager/6044a67020e04752f962a76f95ff99f6cdb00701/resources/scripts/start.sh
- Fetched 2026-11-27

## What it is

- Wrapper image around GoAccess (built from bundled tarball) + nginx + tini, for NPM log reports.
- Start script banner: `GOAN v1.1.39`.

## Build (Dockerfile)

- Stage `builder`: `FROM alpine:latest`.

  - apk: `build-base libmaxminddb-dev ncurses-dev musl-locales gettext-dev`.
  - Copies `/assests/goaccess/goaccess-1.10.2.tar.gz` (bundled in repo, not downloaded).
  - Builds debug copy in `/goaccess-debug` then `/goaccess` with `./configure --enable-utf8 --enable-geoip=mmdb --with-getline` (debug build adds `--enable-debug`), `make`, `make install`.
  - sed patches `/goaccess/resources/tpls.html` (adds GOAN footer, version span "v1.1.40") and `app.css` (`bottom: 190px` -> `260px`).

- Final stage: `FROM alpine:latest`.

  - apk: `bash nginx tini wget curl apache2-utils libmaxminddb tzdata gettext musl-locales ncurses`; removes `/etc/nginx/nginx.conf`.
  - Copies `/goaccess-debug`, `/goaccess`, `/usr/local/share/locale` from builder.
  - Copies `resources/goaccess/goaccess.conf` -> `/goaccess-config/goaccess.conf.bak`.
  - Copies three MaxMind mmdb files from `assests/maxmind/` to `/goaccess-config/` (GeoLite2-City, -ASN, -Country).
  - Copies `resources/nginx/nginx.conf` -> `/etc/nginx/nginx.conf`; ADD `resources/nginx/.htpasswd` -> `/opt/auth/.htpasswd`.
  - `/goan` holds `funcs/`, `logs/`, `start.sh` (chmod +x).
  - `mkdir -p /goaccess-logs/archives`.

- `VOLUME ["/opt/log"]`, `EXPOSE 7880`.
- `ENTRYPOINT ["tini", "--", "/goan/start.sh"]`. No `USER` (runs as root). No HEALTHCHECK.

## Runtime deps

- nginx, tini, bash, curl, wget, apache2-utils (htpasswd), libmaxminddb, tzdata, gettext, ncurses, musl-locales.

## start.sh flow

1. Sources `funcs/internal.sh`, `funcs/environment.sh`, `logs/{npm,npm_redirection,npm_error,traefik,custom,ncsa_combined,nginx_access,caddy}.sh`.
2. `goan_log_path="/opt/log"`; `goaccess_debug_file=/goaccess-logs/goaccess.debug`; `goaccess_invalid_file=/goaccess-logs/goaccess.invalid`; ping interval 15.
3. `nginx_basic_auth`; creates `/var/www/html` if missing; `tini -s -- nginx`.
4. Copies `/goaccess/config/browsers.list` -> `/goaccess-config/browsers.list` (replaces existing).
5. If `CUSTOM_BROWSERS` set: appends `Browser<TAB>Category` entries not already present.
6. Dispatch on `LOG_TYPE`:

   - empty, `NPM`, `NPM+R`, `NPM+ALL`: `npm`; `NPM+R` adds `npm_redirect`; `NPM+ALL` adds `npm_redirect` + `npm_error`.
   - `TRAEFIK`: `traefik`. `NCSA_COMBINED`: `ncsa_combined`. `NGINX_ACCESS`: `nginx_access`. `CADDY_V1`: `caddyV1`.
   - `CUSTOM`: requires `/opt/custom` to exist and be writable, else exit 1.

7. `wait -n` (keeps container running).

## Env vars read by start.sh (directly)

| Var | Use |
| --- | --- |
| CUSTOM_BROWSERS | `Browser:Category,...` appended to browsers.list |
| LOG_TYPE | selects log parser (see above) |

- Other env vars are read inside sourced `funcs/` and `logs/` scripts (not fetched).

## Ports

- nginx serves on port set in its config (not fetched); EXPOSE 7880.
- Conflict: wrapper `npm.sh` (not fetched) writes `port 7890` into generated GoAccess config per plan.md. Unverified here.

## Volumes/paths

- Logs: `/opt/log` (VOLUME). Custom: `/opt/custom` (README mount).
- Config: `/goaccess-config/`. Logs/state: `/goaccess-logs/`. Auth: `/opt/auth/.htpasswd`.
- Static html: `/var/www/html`.

## Gotchas

- Version mismatch in upstream: start.sh banner `GOAN v1.1.39` vs sed string `v1.1.40` in Dockerfile.
- Bundled binary inputs (`assests/goaccess/*.tar.gz`, `assests/maxmind/*.mmdb`) are in-repo; not downloaded.
- Build stages use `alpine:latest` (unpinned).
