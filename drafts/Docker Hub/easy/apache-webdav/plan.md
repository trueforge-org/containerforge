# apache-webdav — implementation plan
> Source: ./draft.md · Target: apps/apache-webdav/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 2.4.66 (Apache httpd as packaged in Ubuntu 26.04: `apache2 2.4.66-2ubuntu2.7`, security pocket, amd64 and arm64). The draft container `apachewebdav/apachewebdav:latest` is a rolling third-party image (mgutt/docker-apachewebdav, based on `httpd:2.4.43-alpine` in its current Dockerfile), so the image version is the httpd version we ship, not that wrapper's. |
| Renovate | None active, following `apps/valkey` (its repology line is commented out). A `github-tags` rule on `apache/httpd` would bump `VERSION` to releases Ubuntu does not package and break the `VERSION`/`PACKAGE_VERSION` guard. Both are bumped by hand. UNVERIFIED: a working repology/deb rule for the Ubuntu revision. |
| License | Apache-2.0 (httpd). The mgutt wrapper scripts and conf are MIT (derived from Bytemark, "Copyright (c) 2019 Bytemark Hosting"); they are not copied verbatim, only the behaviour is reimplemented, so bake `LICENSE` = `Apache-2.0`. |
| Source URL | https://github.com/apache/httpd (docs https://httpd.apache.org/docs/2.4/mod/mod_dav.html) |
| Binary | apt `apache2` (depends on `apache2-bin`, `apache2-data`, `apache2-utils`; `htpasswd` is in `apache2-utils`). Modules confirmed in the apache2 package file list: `dav.load`, `dav_fs.load`, `dav_lock.load`, `auth_digest.load`, `authn_file.load`, `headers.load`, `rewrite.load`; `/usr/sbin/apache2ctl`. |
| Checksum | Not applicable: apt verifies package signatures. |
| Upstream Dockerfile reviewed | https://github.com/mgutt/docker-apachewebdav/blob/master/Dockerfile (+ `docker-entrypoint.sh`, `conf/conf-available/dav.conf`, `conf/sites-available/default.conf`, README) |
| Env vars (wrapper README and entrypoint) | `SERVER_NAMES` (default `localhost`), `LOCATION` (`/`), `AUTH_TYPE` (`Basic` or `Digest`, default Basic), `REALM` (`WebDAV`), `USERNAME`, `PASSWORD` (single user; ignored if `/user.passwd` exists), `ANONYMOUS_METHODS` (comma list or `ALL`), `SSL_CERT` (`selfsigned`), `PUID`, `PGID` (default 1000), `PUMASK`. |
| Paths | Data `/var/lib/dav/data`, lock DB `/var/lib/dav/DavLock`, users `/user.passwd`, certs `/cert.pem` `/privkey.pem`. Upstream dav.conf: `DavLockDB`, `Alias / /var/lib/dav/data/`, `Dav On`, `Options +Indexes`, `DirectoryIndex disabled`, `AuthType Basic`, `AuthUserFile /user.passwd`, `Require valid-user`; vhost `*:80` with `RequestHeader edit Destination ^https http early`. |
| Ports | 80 and 443 upstream; here 8080 only (draft: 8080/http). |

## 2. Target layout

```
apps/apache-webdav/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  etc/httpd.conf.template     # config template, rendered to /tmp at start
```
`etc/` is in the `.dockerignore` allow-list and is copied by `COPY --chmod=0755 . /` to `/etc/`; use a dedicated name, e.g. `etc/apache-webdav/httpd.conf.template`, so it never overlaps `/etc/apache2`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Why: draft says httpd from apt on ubuntu. Closest sibling: `apps/valkey` (pinned apt version `PACKAGE_VERSION` checked against `VERSION`); `apps/phpmyadmin` for the web-server-on-ubuntu pattern (it uses php's built-in server instead of Apache; `apps/nginx` exists but is a different server).

## 4. Dockerfile

1. `FROM`; `ARG VERSION`, `ARG PACKAGE_VERSION`; `USER root`.
2. Pinned apt install, with the version guard copied from `apps/valkey/Dockerfile`:
   ```dockerfile
   RUN test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
       apt-get update && \
       apt-get install -y --no-install-recommends "apache2=${PACKAGE_VERSION}" && \
       apt-get purge -y --auto-remove && \
       rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
       mkdir -p /usr/share/licenses/apache-webdav && \
       cp /usr/share/doc/apache2/copyright /usr/share/licenses/apache-webdav/copyright && \
       test -f /usr/lib/apache2/modules/mod_dav_fs.so
   ```
   Do not add the `a2enmod` steps: they write under `/etc/apache2`, which is fine at build time but unnecessary because the runtime config loads modules explicitly. `apache2` installs `/etc/apache2` with default mods and a `www-data` user; the runtime config below ignores them. `gettext-base` (`envsubst`), `coreutils` (`md5sum`) and `bash` are already in the base. Remove the default site files only if they cause confusion; they are unused with `-f`.
3. `ENV` nothing app-specific besides the documented defaults (`AUTH_TYPE=Basic`, `REALM=WebDAV`, `LOCATION=/`, `SERVER_NAMES=localhost`, `PUMASK=0022`); keep them identical to `start.sh` and `settings.yaml`.
4. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `WORKDIR /config`, `VOLUME /config`, `VOLUME /data`. Final `USER apps`. (The base creates `/data` owned by `apps`; the DAV share lives there.)

## 5. docker-bake.hcl

- `APP` = `apache-webdav`
- `VERSION` and `PACKAGE_VERSION`:
  ```hcl
  variable "VERSION" {
    // NOTE: Ubuntu version, tied to the base image; no active renovate comment (as apps/valkey)
    default = "2.4.66"
  }
  variable "PACKAGE_VERSION" {
    // NOTE: Ubuntu 26.04 package revision, tied to the base image; bump by hand with VERSION
    default = "2.4.66-2ubuntu2.7"
  }
  ```
  `PACKAGE_VERSION` must also be passed in `target "image"` `args` (like `apps/valkey/docker-bake.hcl`: check how it forwards both). The `.7` security revision will be superseded and removed from the archive; expect to bump it. Both arches had the same revision on 2026-11-23.
- `LICENSE` = `Apache-2.0`; `SOURCE` = `https://github.com/apache/httpd`
- 4 targets and `default` group as in `apps/valkey/docker-bake.hcl`; `docker buildx bake --print`.

## 6. settings.yaml

- Header, `schema_version: 1`, `upstream_env_url: "https://github.com/apache/httpd"`.
- `ports`: `8080` tcp `required: false`.
- `env` (all read by `start.sh`, names kept compatible with the draft's `apachewebdav` image): `SERVER_NAMES` "localhost", `LOCATION` "/", `AUTH_TYPE` "Basic", `REALM` "WebDAV", `USERNAME` "", `PASSWORD` "", `ANONYMOUS_METHODS` "", `PUMASK` "0022", `TZ` "Etc/UTC". All `required: false`.
- Dropped from upstream and not listed: `SSL_CERT` (TLS belongs on a reverse proxy; port 443 not offered), `PUID`, `PGID` (the container runs as UID 568; use the pod or container user and `fsGroup` instead).
- `volumes`: `/config` required true (user file, lock DB, generated state); `/data` required true (the shared files).
- `dependencies`: none.

## 7. start.sh

Behaviour (write it as an idempotent bash script; render the config into `/tmp` every start):
1. `umask "${PUMASK:-0022}"` (the draft's chart sets `0000` world-writable; keep opt-in, default stricter).
2. `mkdir -p /config/dav /data /tmp/apache2`.
3. Users file: if `/config/user.passwd` exists, use it (user managed, e.g. several users via `htpasswd -B`). Else build `/tmp/apache2/user.passwd` on each start from env (so a changed password applies on restart):
   - `AUTH_TYPE=Basic`: `printf '%s' "$PASSWORD" | htpasswd -B -i -c /tmp/apache2/user.passwd "$USERNAME"` (the password is read from stdin, so it is not in the process list).
   - `AUTH_TYPE=Digest`: `hash=$(printf '%s' "$USERNAME:$REALM:$PASSWORD" | md5sum | cut -d' ' -f1)`; write `$USERNAME:$REALM:$hash` (same as upstream).
   - Any other `AUTH_TYPE`: print an error and `exit 1` (upstream does the same). Without `USERNAME` and `PASSWORD`: create an empty file (nobody can log in, 401), and log that.
   - Reject `USERNAME` containing `:`.
4. `ANONYMOUS_METHODS`: `ALL` replaces `Require valid-user` by `Require all granted`; a list becomes an extra `Require method GET PROPFIND ...` line (commas to spaces; accept only `[A-Z, ]`).
5. Render `/etc/apache-webdav/httpd.conf.template` to `/tmp/apache2/httpd.conf` with `envsubst` and an explicit variable list (`'${LOCATION} ${REALM} ${AUTH_TYPE} ${SERVER_NAME} ${AUTH_FILE} ${REQUIRE_LINES}'`) so Apache's own `${...}` are not touched; keep user input out of the sed expressions.
6. `exec /usr/sbin/apache2 -f /tmp/apache2/httpd.conf -DFOREGROUND`.

Template content (key directives; all paths writable):
- `ServerRoot /etc/apache2`, `Listen 8080`, `ServerName ${SERVER_NAME}`, `PidFile /tmp/apache2/httpd.pid`, `DefaultRuntimeDir /tmp/apache2`, `Mutex file:/tmp/apache2 default`, no `User` or `Group` (running as non-root).
- `LoadModule` lines from `/usr/lib/apache2/modules/` (relative to `ServerRoot` as `/usr/lib/apache2/modules/mod_X.so`): `mpm_event`, `authn_core`, `authn_file`, `authz_core`, `authz_user`, `authz_host`, `auth_basic`, `auth_digest`, `dav`, `dav_fs`, `alias`, `autoindex`, `dir`, `mime`, `setenvif`, `headers`, `env`, `reqtimeout`. Do not add `LoadModule` for `log_config` or `unixd`: Debian's `apache2` builds them in, so there is no `.so` to load (UNVERIFIED for this exact package; confirm with `apache2 -l`). `TypesConfig /etc/mime.types` if present (check).
- `ErrorLog /proc/self/fd/2`, `CustomLog /proc/self/fd/1 combined` (needs a `LogFormat` line defined in the template).
- `DavLockDB /config/dav/DavLock`, `Alias ${LOCATION} "/data/"` (careful with `LOCATION=/`), `<Directory "/data/">` with `Dav On`, `Options +Indexes`, `DirectoryIndex disabled`, `AuthType ${AUTH_TYPE}`, `AuthName "${REALM}"`, `AuthUserFile ${AUTH_FILE}`, `<RequireAny>` with `Require valid-user` plus optional extra lines.
- The `BrowserMatch ... redirect-carefully` lines and `RequestHeader edit Destination ^https http early` from the upstream conf (needed for common clients and TLS-terminating proxies).
- A default vhost behaviour: document root `/tmp/apache2/empty` with `Require all denied` for anything outside `LOCATION`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8080'
http:
- port: '8080'
  path: /
  statusCode: 401
filePaths:
- /usr/sbin/apache2
- /usr/lib/apache2/modules/mod_dav_fs.so
- /etc/apache-webdav/httpd.conf.template
- /usr/share/licenses/apache-webdav/copyright
```
With no env, the user file is empty, so every request must get a `401` challenge; that proves Apache, `mod_dav` auth and the config work. A non-2xx `statusCode` is supported: the forgetool schema takes any integer and `include/healthcheck.sh` requires an exact match when `statusCode` is set. The credentialed path (`USERNAME`/`PASSWORD`, `PROPFIND`, `PUT`, `GET`) cannot run in the harness and must be run by hand (section 11). Not a DB-dependent app.

## 9. Rootless and read-only-rootfs adaptations

| Upstream (or Debian default) write path | Remap |
|---|---|
| Port 80 and 443 | `Listen 8080`; SSL not offered. |
| `/var/run/apache2` pid file and runtime dir, mutex and `ScriptSock` | `/tmp/apache2` (`PidFile`, `DefaultRuntimeDir`, `Mutex file:`). |
| `/var/log/apache2` | Logs to `/proc/self/fd/1` and `/proc/self/fd/2`. |
| `/var/lib/dav/DavLock` | `/config/dav/DavLock` (mod_dav_fs writes DBM files with a suffix next to it). |
| `/var/lib/dav/data` | `/data` (volume). |
| `/user.passwd` | `/config/user.passwd` if the user provides it, else generated in `/tmp/apache2/user.passwd` each start. |
| `/etc/apache2/*` edits by sed at start (upstream edits conf in place) | Config rendered to `/tmp` from a template; `/etc` is never modified at runtime. |
| `User`/`Group` switch (PUID, PGID) | Removed; Apache runs as UID 568 and must not set `User`/`Group`. |

Draft expectations: chart runs as UID 0 and a writable rootfs; both are dropped, the image runs as `apps` with a read-only rootfs. `PUMASK=0000` from the chart remains possible as an opt-in env value. Extra persistence `/var/lib/dav/data` becomes `/data` (document the mount change for chart users, and that DavLock state moves to `/config/dav`). Not privileged.

## 10. Risks, caveats and open questions

- Draft: multiple users must be created by hand (upstream generates its config and a single user from env); here a generated config exists and an empty user file denies all access until `USERNAME` and `PASSWORD` or `/config/user.passwd` is supplied.
- Draft: third-party rolling image, not an Apache release: replaced by Ubuntu's `apache2`; behaviour is reimplemented, so it may differ in details (index layout, Windows client quirks). Windows Mini-Redirector over plain HTTP requires `Digest` or a registry change; document it.
- Version tracking: the Ubuntu security revision `2.4.66-2ubuntu2.7` will move; the build will fail loudly on a stale pin (by design), but renovate cannot automate it (UNVERIFIED repology option).
- UNVERIFIED: apache2's non-root start with `-f` (the Debian `apache2ctl` envvars are bypassed; modules path, `Mutex` and `ScriptSock` for mod_cgid are not needed because cgid is not loaded); confirm no `AH00023`/permission errors in logs.
- UNVERIFIED: Debian's `apache2` may include `/etc/apache2/envvars` assumptions only for `apache2ctl`; running `apache2` directly avoids them.
- Security: Basic auth over plain HTTP exposes the credentials; recommend Digest or a TLS reverse proxy. `ANONYMOUS_METHODS=ALL` disables auth.
- Not blockers: no musl, no GPU, no privileged, arm64 package exists.

## 11. Build and test steps

```sh
cd apps/apache-webdav
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name apache-webdav-probe --read-only --tmpfs /tmp -v apache-webdav-probe-config:/config -v apache-webdav-probe-data:/data apache-webdav:2.4.66
docker logs -f apache-webdav-probe     # expect "AH00094: Command line: ... apache2 -f /tmp/apache2/httpd.conf -DFOREGROUND" and no AH00015 or permission errors
curl -si http://<container-ip>:8080/ | head -3    # 401 Unauthorized with WWW-Authenticate
docker rm -f apache-webdav-probe
# credentialed run
docker run --rm -d --name apache-webdav-probe --read-only --tmpfs /tmp -e USERNAME=alice -e PASSWORD='p@ss w0rd' -v apache-webdav-probe-config:/config -v apache-webdav-probe-data:/data apache-webdav:2.4.66
curl -u alice:'p@ss w0rd' -T README http://<ip>:8080/test.txt ; curl -u alice:'p@ss w0rd' -X PROPFIND -H 'Depth: 1' http://<ip>:8080/
docker restart apache-webdav-probe     # idempotent
# repeat with -e AUTH_TYPE=Digest (curl --digest)
docker rm -f apache-webdav-probe; docker volume rm apache-webdav-probe-config apache-webdav-probe-data
forgetool containers test --image apache-webdav:2.4.66 --config ./apps/apache-webdav/container-test.yaml
```
Success: Apache stays up on the read-only rootfs, 401 without credentials, 201 on `PUT` and 207 on `PROPFIND` with credentials, the data lands in `/data`. Max 10 rounds, fresh volumes each round.

## 12. PR checklist

- Branch `feat/add-apache-webdav`; commit and title `feat(apache-webdav): add new container`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes has `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested unless run: both arches, Basic and Digest auth flows, anonymous methods, real WebDAV clients (Windows, macOS, Linux), `PUMASK`, migration from the chart's `/var/lib/dav`, `forgetool` run.
- Standard checklist: minimal scope, instruction files followed, `VERSION` and `PACKAGE_VERSION` aligned with the Dockerfile guard, rootless and read-only, empty `/config` works, no downstream impact, `bake --print` ran.
