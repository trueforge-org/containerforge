# trango — implementation plan
> Source: ./draft.md · Target: apps/trango/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | No releases or tags exist. Pin the git commit `4ba53cf75f9b2eb7bc2cdfaefaca29fd35ed11a8` (HEAD of `master`, last commit dated 2020-11-23 per `git log`). Docker Hub image `tak786/trango-self-hosted:latest` is unversioned, so the draft's `latest` is not usable as a version |
| Renovate | `datasource=git-refs depName=trango-io/trango-self-hosted packageName=https://github.com/trango-io/trango-self-hosted` (same pattern as `KASM_NOVNC_VERSION` in `apps/kasmvnc/docker-bake.hcl`). Since the repo is dormant, renovate will rarely fire. `VERSION` for tagging purposes: use the short sha or `0.0.0-<date>` (decide; UNVERIFIED which tag scheme CI expects) |
| License | GPL-2.0 (LICENSE is the GPL version 2 text; README says "Distributed under the GPL-2.0 License"). SPDX `GPL-2.0-only` is assumed (the "or later" clause was not checked: UNVERIFIED) |
| Source URL | https://github.com/trango-io/trango-self-hosted (the same commit is also reachable under the `mmurtaznaqvi/` owner name; the repo was renamed/transferred) |
| Download | Source tarball `https://github.com/trango-io/trango-self-hosted/archive/<sha>.tar.gz` (compile for both archs, no prebuilt binary) |
| Checksum source | None published. Pin the git commit sha (content-addressed). Optionally add a sha256 of the tarball |
| Upstream Dockerfile reviewed | master `Dockerfile`: ubuntu:18.04; apt `libboost-all-dev libssl-dev g++ nginx python3.6 python3-pip curl`; nodesource setup_12.x; `pip3 install flask_restful flask_cors psutil`; copies `discoveryserver/` to `/home/discoveryserver/` and `app/` to `/home/app/`; copies the repo's committed `nginx-selfsigned.crt/key`, `dhparam.pem`, `ssl.conf`, `default`; `npm i && npm run build` in `/home/app`; `g++ main.cpp WebSocketMainWS.cpp WebSocketWS.cpp -I ../lib/SimpleWebSocketServer/ -lboost_system -lssl -lcrypto -lpthread -o WebSocketWS`; `EXPOSE 80 443`; `CMD ./run.sh` |
| Processes (run.sh, ssl.conf, api.py, main.cpp) | nginx on 80 (301 redirect to https) and 443 (TLS, serves `/home/app/build/`); Flask API `app.run(host='0.0.0.0', port=8081)` for `POST /checkurl`; C++ WebSocket discovery server `WebSocketWS` on port 8443 (from `config.ini` `[server] port`, default 8443), proxied by nginx at `/server/`; the frontend connects to `wss://<host>/server/` |
| Env vars | None read by upstream code (config is `config.ini` and hard-coded) |

Corrections to the draft: port 3000 is wrong. Upstream serves 80 and 443 (container side), with internal 8081 and 8443. Python 3.6 / Node 12 are Ubuntu 18.04 era; the app is built here with current runtimes (see risks).

## 2. Target layout

```
apps/trango/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/nginx.conf.tpl     # nginx main + server config, rendered to /tmp at start
  defaults/config.ini         # discovery server config template (port)
```
`defaults/` is needed because nginx and the WebSocket server both need configs outside the read-only `/app`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Final stage: `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (Flask API in `/app/venv`, nginx from apt). Build stages: web stage `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS web` (the React 16 / react-scripts 3.4.1 build) and C++ stage `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS ws` (g++, boost, openssl). Closest siblings: `apps/kasmvnc` (multi-stage with python-node + ubuntu build stages and nginx in /tmp), `apps/bazarr` (python final stage). Node version shipped in python-node: UNVERIFIED.

## 4. Dockerfile

1. Stage `web`: `USER root`, `ARG VERSION` (commit sha); `curl -fsSL https://github.com/trango-io/trango-self-hosted/archive/${VERSION}.tar.gz | tar -xz --strip-components=1 -C /src`; `cd /src/app && NODE_OPTIONS=--openssl-legacy-provider npm ci --legacy-peer-deps` (a `package-lock.json` and `yarn.lock` both exist) `&& npm run build`. `NODE_OPTIONS=--openssl-legacy-provider` is needed for webpack 4 on Node 17+: UNVERIFIED, remove if the build passes without it. Keep all caches in `/tmp` (`npm_config_cache=/tmp/npm`).
2. Stage `ws`: `apt-get install -y --no-install-recommends g++ libboost-system-dev libssl-dev`; same source; `cd discoveryserver/src && g++ main.cpp WebSocketMainWS.cpp WebSocketWS.cpp -I ../lib/SimpleWebSocketServer/ -lboost_system -lssl -lcrypto -lpthread -o /out/WebSocketWS` (the upstream command; modern boost/g++ compatibility UNVERIFIED, may need `-std=c++17` or `-DBOOST_BIND_GLOBAL_PLACEHOLDERS`).
3. Final stage: `ARG VERSION`, `USER root`; apt `nginx libssl3 libboost-system1.90.0` (runtime lib package name for 26.04 UNVERIFIED; check `ldd`) and `openssl` (CLI is already in base via `libssl3`? the CLI is not guaranteed; add `openssl`); do not re-install curl, ca-certificates, python (base has them).
4. pip into the base venv: `/app/venv/bin/pip install --no-cache-dir flask flask-restful flask-cors` (upstream also installs `psutil` for the restart watchdog, which we replace with a start.sh `wait -n`). Pin versions after checking (UNVERIFIED which versions work with `flask_restful`; `flask-restful` 0.3.10 with current Flask is known to break on some versions).
5. `COPY --from=web /src/app/build /app/www`, `COPY --from=web /src/app/api.py /app/api/api.py`, `COPY --from=ws /out/WebSocketWS /app/bin/WebSocketWS`; license: `COPY --from=web /src/LICENSE /usr/share/licenses/trango/LICENSE`.
6. nginx writable dirs: `sed` the packaged `/etc/nginx/nginx.conf` pid and logs to `/tmp` like `apps/kasmvnc/Dockerfile` does (`pid /tmp/nginx.pid`, error/access logs to /tmp); `chown -R apps:apps /var/lib/nginx /var/log/nginx` as in kasmvnc.
7. `ENV HOME=/config`. Do NOT copy the repo's `nginx-selfsigned.key/crt/dhparam.pem` (a private key committed in public git); a cert is generated at first start.
8. `USER apps` as the last user directive; `COPY --chmod=0755 . /`; `EXPOSE 8080 8443`; `VOLUME /config`; `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "trango" }

variable "VERSION" {
  // renovate: datasource=git-refs depName=trango-io/trango-self-hosted packageName=https://github.com/trango-io/trango-self-hosted
  default = "4ba53cf75f9b2eb7bc2cdfaefaca29fd35ed11a8"
}

variable "LICENSE" { default = "GPL-2.0-only" }
variable "SOURCE"  { default = "https://github.com/trango-io/trango-self-hosted" }
```
`image.args.VERSION = "${VERSION}"` and the standard `image`, `image-local` (tag `${APP}:${VERSION}`), `image-all` (amd64 + arm64), `group "default"`. A 40-char tag is ugly; the implementer may add a short-tag variable if CI allows (UNVERIFIED). Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/trango-io/trango-self-hosted"
ports:
  - port: 8080
    protocol: tcp
    required: false
  - port: 8443
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```
Ports 80/443 become 8080/8443 because the process is non-root (ports below 1024 need extra capability). Internal 8081 (API) and the discovery server port are loopback only and not listed. Draft's 3000 is dropped (not used upstream). Env: only `TZ` (upstream reads nothing). Dependencies: none.

## 7. start.sh

1. `mkdir -p /config/ssl /tmp/nginx /tmp/trango`; if `/config/ssl/cert.pem` is missing, generate with `openssl req -x509 -newkey rsa:4096 -nodes -days 3650 -subj "/CN=trango" -keyout /config/ssl/key.pem -out /config/ssl/cert.pem` and `chmod 600` the key (seed only when missing, like `apps/kasmvnc/start.sh`).
2. Render `/defaults/nginx.conf.tpl` to `/tmp/trango/nginx.conf`: `listen 8080` (301 to `https://$host:8443`), `listen 8443 ssl http2` (cert from `/config/ssl`), `root /app/www`, `location /server/` proxy to `http://127.0.0.1:9443/server` (WebSocket upgrade headers as in upstream `ssl.conf`), `location /checkurl` proxy to `http://127.0.0.1:8081/checkurl`; `pid /tmp/trango/nginx.pid`, temp paths and logs in `/tmp`. Drop upstream TLSv1/1.1 and `ssl_stapling` with a hard-coded Google resolver; use TLSv1.2/1.3.
3. `cp /defaults/config.ini /tmp/trango/config.ini` with `port=9443`, and run the WebSocket server from `cd /tmp/trango` because it reads `config.ini` from its working directory (`INIReader reader("config.ini")` in main.cpp). The internal port moves from 8443 to 9443 so nginx can own 8443.
4. `/app/venv/bin/python /app/api/api.py &` (it listens on `0.0.0.0:8081` hard-coded; to keep it loopback-only, run it through `flask`/`waitress` bound to 127.0.0.1 or patch with `sed` at build time: UNVERIFIED).
5. `/app/bin/WebSocketWS &`.
6. Final: `exec nginx -c /tmp/trango/nginx.conf -g 'daemon off;'`, but because the other two children must also be supervised, use `wait -n` pattern: start nginx in background too and `wait -n; exit 1` so the orchestrator restarts a crashed container (replaces upstream's `py_fail.py` watchdog). Add `trap 'kill 0' TERM INT` for signal propagation. If strict "exec the final process" is preferred, exec nginx last and accept that API/WS crashes are not detected (not recommended).
7. All scratch and rendered config in `/tmp`; persistent only `/config/ssl`. Nothing written to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8080'
- port: '8443'
filePaths:
- /app/www/index.html
- /app/bin/WebSocketWS
- /app/api/api.py
- /usr/share/licenses/trango/LICENSE
```
Both settings.yaml ports (8080, 8443) have a probe. The tcp probe on 8443 passes for a TLS listener at TCP level. No DB, no narrowing.

## 9. Rootless and read-only-rootfs adaptations

- Draft/chart expects UID 0 and writable rootfs; upstream runs everything as root and binds 80/443. We run as `apps` with 8080/8443.
- Writes remapped: nginx pid/logs/temp -> `/tmp`; rendered nginx config and `config.ini` -> `/tmp/trango`; TLS cert/key -> `/config/ssl`; npm/pip caches -> `/tmp` at build time. `/home/app` and `/home/discoveryserver` upstream paths are replaced by `/app/www`, `/app/api`, `/app/bin`.
- Security: the repo's committed private key and `dhparam.pem` are not used. `api.py` contains hard-coded `SECERT_KEY1/2` strings for `/checkurl` (upstream design; cannot be changed without patching): document in the PR.
- No extra persistence (draft: none beyond `/config`).

## 10. Risks, caveats and open questions

- Dormant upstream: last commit 2020-11-23, no releases, React 16 / react-scripts 3.4.1 / Node-12-era toolchain; the web build on current Node may fail without legacy flags and with unpatched npm audit issues.
- Hard-coded secret keys in `api.py`, and `CORS(app)` open to all origins; the API binds `0.0.0.0` by default.
- WebRTC needs HTTPS: users get a self-signed cert warning unless they mount their own cert in `/config/ssl`.
- Frontend assumes `wss://<host>/server/` on the same origin, so the TLS port must be the one browsers use (8443 mapped as is, or behind a reverse proxy that terminates TLS and forwards WebSocket to 8080 would break because the 8080 server redirects); a plain-HTTP reverse-proxy mode is not supported: UNVERIFIED how the app behaves behind TLS-terminating proxies.
- C++ build: boost and gcc versions on 26.04 vs 2020 code: UNVERIFIED.
- Upstream Docker Hub image is `latest` with no tags; the copy-from option in the draft is therefore not pinnable and is not used.
- UNVERIFIED count for this plan: 8 (SPDX or-later, Node version, openssl legacy flag, boost lib package, flask-restful pin, API bind, short tag scheme, reverse-proxy behaviour).

## 11. Build and test steps

```sh
cd apps/trango
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create trango-probe-config
docker run --rm -d --name trango-probe --read-only --tmpfs /tmp \
  -v trango-probe-config:/config trango:4ba53cf75f9b2eb7bc2cdfaefaca29fd35ed11a8
docker logs -f trango-probe
```
Readiness signals: nginx starts without `[emerg]`, `curl -sk https://localhost:8443/` from outside returns the React `index.html`, `curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/` returns 301, a WebSocket upgrade to `/server/` is accepted, and `/config/ssl/cert.pem` exists after first start; all three child processes alive. Then:
```sh
forgetool containers test --image trango:4ba53cf75f9b2eb7bc2cdfaefaca29fd35ed11a8 --config ./apps/trango/container-test.yaml
docker rm -f trango-probe; docker volume rm trango-probe-config
```
Optionally build arm64 only if the amd64 loop is green.

## 12. PR checklist

- Branch `feat/add-trango`; commit and PR title `feat(trango): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes contain `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign).
- Pre-completion: bake print ok; `ARG VERSION` equals bake `VERSION`; final `USER apps`; `COPY --chmod=0755 . /`; license in `/usr/share/licenses/trango/`; no committed key material.
- State untested: arm64 build, WebRTC call between two browsers, behind-proxy behaviour, Node/boost toolchain compatibility until the loop is run.
