# omada-controller — implementation plan
> Source: ./draft.md · Target: apps/omada-controller/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `6.3.0.111` (mbentley README: tags `6`/`6.3` = 6.3.0.111; 6.2 = 6.2.14.11; beta 6.4.0.33; `latest` still points at 5.15, do not use). Draft tag `6.3` maps to 6.3.0.111. |
| Renovate | `datasource=docker depName=mbentley/omada-controller versioning=loose` (TP-Link has no machine-readable release feed; the mbentley tag tracks it). Tags like `beta-6.4.0.33` need `allowedVersions`/filter in renovate config (UNVERIFIED). |
| License | Omada software: TP-Link proprietary EULA (not verified). The mbentley wrapper repo is AGPL-3.0. Use `LICENSE = "LicenseRef-TP-Link-Omada-EULA"` UNVERIFIED; redistribution rights of the TP-Link tarball in a public image are UNVERIFIED and may block this port. |
| Source URL | https://www.tp-link.com/en/omada-sdn/ (wrapper: https://github.com/mbentley/docker-omada-controller) |
| Download | Resolved through mbentley's resolver: `https://omada-controller-url.mbentley.net/hooks/omada_ver_to_url?omada-ver=6.3.0.111` returned `https://static.tp-link.com/upload/software/2026/202610/20261016/Omada_Network_Application_v6.3.0.111_linux_x64_20261009150926.tar.gz`. It is a `.tar.gz` (not a .deb as the draft says) with a `Omada_Network_Application_*` top dir; install copies `bin data lib properties install.sh uninstall.sh` to `/opt/tplink/EAPController` (v6). The same archive serves both arches (mbentley's `ARCH` only selects MongoDB packages): arm64 UNVERIFIED for the archive contents, the upstream image is multi-arch amd64+arm64. |
| Checksum | None published by TP-Link or mbentley (install.sh does no verification). Plan: compute sha256 once during implementation and pin it in a Dockerfile `ARG OMADA_SHA256` (UNVERIFIED value). |
| MongoDB | v6 uses MongoDB 8.0 (install.sh adds repo.mongodb.org 8.0 for amd64/arm64). Embedded mongod listens on `127.0.0.1:27217` (default `EAP_MONGOD_URI=mongodb://127.0.0.1:27217/omada`), NOT 27017 as the draft guessed. Existing `apps/mongodb` ships 9.0.4: compatibility with Omada UNVERIFIED, so embed 8.0.x. `https://fastdl.mongodb.org/linux/mongodb-linux-aarch64-ubuntu2404-8.0.38.tgz` returns 200 (x86_64 8.0.30 also 200; latest 8.0.x UNVERIFIED), `.sha256` file alongside as used by `apps/mongodb/Dockerfile`. |
| Java | install.sh picks `openjdk-17-jre-headless` for v6. Use java17 base. |
| Ports (upstream image) | EXPOSE 8044, 8088, 8043, 8843, 19810/udp, 27001/udp, 29810/udp, 29811-29817/tcp. Defaults: `MANAGE_HTTP_PORT` 8088, `MANAGE_HTTPS_PORT` 8043, `PORTAL_HTTP_PORT` 8088, `PORTAL_HTTPS_PORT` 8843, `PORT_APP_DISCOVERY` 27001, `PORT_DISCOVERY` 29810, `PORT_MANAGER_V1` 29811, `PORT_ADOPT_V1` 29812, `PORT_UPGRADE_V1` 29813, `PORT_MANAGER_V2` 29814, `PORT_TRANSFER_V2` 29815, `PORT_RTTY` 29816, `PORT_DEVICE_MONITOR` 29817, `UPGRADE_HTTPS_PORT` 8043 (<6.4) / 8044 (6.4+). All unprivileged (>1024 except none), good for rootless. |
| Env vars (README) | `PUID/PGID` (not used in rootless mode), `SHOW_SERVER_LOGS` true, `SHOW_MONGODB_LOGS` false, `SSL_CERT_NAME` tls.crt, `SSL_KEY_NAME` tls.key, `TZ` Etc/UTC, `ROOTLESS` false, `MONGO_EXTERNAL` false, `EAP_MONGOD_URI`, `JAVA_MAX_HEAP_SIZE`, `JAVA_MIN_HEAP_SIZE`, `MONGOD_EXTRA_ARGS` (not supported rootless), `WEB_CONFIG_OVERRIDE`. |
| Volumes (upstream) | `/opt/tplink/EAPController/data`, `/opt/tplink/EAPController/logs`; `work` no longer needed since 5.0.x (README); `/cert` for TLS. |
| Entrypoint behaviour | `entrypoint-unified.sh`: in rootless mode refuses UID/GID 0, only checks data/logs/properties and `/tmp` are writable; restores `properties/` from `properties.defaults`; extracts `data/html` from `data-html.tar.gz`; seds `omada.properties` for port env vars; execs `java -server -Xms128m -Xmx1024m ... -cp /opt/tplink/EAPController/lib/*:/opt/tplink/EAPController/properties com.tplink.smb.omada.starter.OmadaLinuxMain` (working dir `.../lib`). Healthcheck: `https://<host>:8043/api/info` (6.2+). |
| Upstream Dockerfile reviewed | https://github.com/mbentley/docker-omada-controller/blob/master/Dockerfile and `install.sh`, `entrypoint-unified.sh` |

## 2. Target layout

```
apps/omada-controller/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
Final file list: `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`. No `defaults/` (properties defaults are taken from the install tree at build time and kept in `/app/omada/properties.defaults`). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a`

Why: Omada v6 runs on JRE 17 (`JAVA_HOME=/opt/java/openjdk` in the base). Closest sibling: `apps/unifi-network-application` (java controller with `/config` symlinks; it uses an external MongoDB, not an embedded one) and `apps/nzbhydra2` (java17 base). MongoDB is embedded: copy the `mongod` extraction pattern from `apps/mongodb/Dockerfile`.

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`, `ARG TARGETARCH`, `ARG OMADA_URL` (default the resolved `static.tp-link.com` URL above; it embeds a build timestamp so it must be updated together with VERSION), `ARG OMADA_SHA256`, `ARG MONGODB_VERSION=8.0.38` (renovate: `datasource=github-tags depName=mongodb/mongo extractVersion=^r(?<version>\d+\.\d+\.\d+)$ versioning=semver`, restrict to 8.0 via `allowedVersions`); `USER root`.
2. Apt (only what the base lacks, check first): `ca-certificates`, `curl`; likely `libcurl4t64` for mongod and `procps`. No `gosu` (rootless).
3. MongoDB: `case "${TARGETARCH}" in amd64) server_arch=x86_64;; arm64) server_arch=aarch64;; esac`; download `https://fastdl.mongodb.org/linux/mongodb-linux-${server_arch}-ubuntu2404-${MONGODB_VERSION}.tgz`, verify with `${url}.sha256` exactly as `apps/mongodb/Dockerfile`, extract only `mongod` into `/usr/local/bin`, licence files to `/usr/share/licenses/mongodb/` (`LICENSE-Community.txt`, `MPL-2`, `THIRD-PARTY-NOTICES`), run `mongod --version`.
4. Omada: `curl -fsSL -o /tmp/omada.tgz "${OMADA_URL}" && echo "${OMADA_SHA256}  /tmp/omada.tgz" | sha256sum -c -`; `tar xzf` to `/tmp/omada`; `cd /tmp/omada/Omada_Network_Application_*`; `mkdir -p /app/omada && cp -r bin data lib properties /app/omada/`; `cp -r /app/omada/properties /app/omada/properties.defaults`; `tar zcf /app/omada/data-html.tar.gz -C /app/omada/data html` then `rm -rf /app/omada/data` (keeps `/app` free of runtime state; entrypoint logic is reproduced in start.sh); then create the build-time links `ln -s /config/data /app/omada/data`, `ln -s /config/logs /app/omada/logs`, `ln -s /tmp/omada-work /app/omada/work` (dangling until `start.sh` creates the targets); assert the version: `grep -r "${VERSION}" /app/omada/lib` or the jar name contains `${VERSION}` (check exact artifact name during implementation, UNVERIFIED). Symlink `ln -s /app/omada /opt/tplink/EAPController` only if the app hard-codes that path (UNVERIFIED; the java classpath is passed explicitly so likely unnecessary).
5. Licence: copy any `LICENSE`/`EULA` text in the tarball to `/usr/share/licenses/omada-controller/` (presence UNVERIFIED); otherwise add a `README` note pointing at the TP-Link EULA URL.
6. `chmod 755 /app/omada/bin/*`; `chown -R root:root /app`; `chmod -R a+rX /app`; `rm -rf /tmp/* /var/lib/apt/lists/*`.
7. ENV: `HOME=/config`, `ROOTLESS=true`, `TZ=Etc/UTC`, `LANG`/`JAVA_HOME` inherited from java17.
8. `USER apps`
9. `COPY --chmod=0755 . /`
10. `EXPOSE 8043 8088 8843 8044 29811 29812 29813 29814 29815 29816 29817` plus `EXPOSE 19810/udp 27001/udp 29810/udp`; `VOLUME /config`; `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" {
  default = "omada-controller"
}

variable "VERSION" {
  // renovate: datasource=docker depName=mbentley/omada-controller versioning=loose
  default = "6.3.0.111"
}

variable "LICENSE" {
  default = "LicenseRef-TP-Link-Omada-EULA"
}

variable "SOURCE" {
  default = "https://www.tp-link.com/en/omada-sdn/"
}
```
Plus `target "docker-metadata-action" {}`, `group "default" { targets = ["image-local"] }`, `image` (args VERSION, OMADA_URL, OMADA_SHA256, MONGODB_VERSION if declared as variables with their own renovate comment; keep Dockerfile ARG defaults identical), `image-local`, `image-all` (amd64, arm64), copied from `apps/adguardhome-sync/docker-bake.hcl` and `apps/mongodb/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.tp-link.com/en/omada-sdn/"
ports:
  - port: 8043
    protocol: tcp
    required: true
  - port: 8088
    protocol: tcp
    required: false
  - port: 8843
    protocol: tcp
    required: false
  - port: 8044
    protocol: tcp
    required: false
  - port: 29811
    protocol: tcp
    required: false
  - port: 29812
    protocol: tcp
    required: false
  - port: 29813
    protocol: tcp
    required: false
  - port: 29814
    protocol: tcp
    required: false
  - port: 29815
    protocol: tcp
    required: false
  - port: 29816
    protocol: tcp
    required: false
  - port: 29817
    protocol: tcp
    required: false
  - port: 19810
    protocol: udp
    required: false
  - port: 27001
    protocol: udp
    required: false
  - port: 29810
    protocol: udp
    required: false
env:
  - name: MANAGE_HTTP_PORT
    default: "8088"
    required: false
  - name: MANAGE_HTTPS_PORT
    default: "8043"
    required: false
  - name: PORTAL_HTTP_PORT
    default: "8088"
    required: false
  - name: PORTAL_HTTPS_PORT
    default: "8843"
    required: false
  - name: PORT_APP_DISCOVERY
    default: "27001"
    required: false
  - name: PORT_DISCOVERY
    default: "29810"
    required: false
  - name: PORT_MANAGER_V1
    default: "29811"
    required: false
  - name: PORT_ADOPT_V1
    default: "29812"
    required: false
  - name: PORT_UPGRADE_V1
    default: "29813"
    required: false
  - name: PORT_MANAGER_V2
    default: "29814"
    required: false
  - name: PORT_TRANSFER_V2
    default: "29815"
    required: false
  - name: PORT_RTTY
    default: "29816"
    required: false
  - name: PORT_DEVICE_MONITOR
    default: "29817"
    required: false
  - name: SHOW_SERVER_LOGS
    default: "true"
    required: false
  - name: JAVA_MAX_HEAP_SIZE
    default: ""
    required: false
  - name: JAVA_MIN_HEAP_SIZE
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
UDP ports (19810, 27001, 29810) are listed with `protocol: udp` (as sibling `apps/emby/settings.yaml` does) but have no probe in `container-test.yaml`, because tcp/http probes cannot test UDP (stated reason; UNVERIFIED whether the test schema has a udp probe). Env names are those read by upstream's entrypoint, and `start.sh` must implement the same defaults. Only port env vars that `start.sh` really maps are listed. `dependencies: []` (MongoDB embedded; draft says none).

## 7. start.sh

Reproduce the rootless branch of `entrypoint-unified.sh` (UNVERIFIED details, re-read the upstream script during implementation):
1. `mkdir -p /config/{data,logs,properties}`; first run: if `/config/properties` is empty, `cp -r /app/omada/properties.defaults/. /config/properties/`; if `/config/data/html` missing, `tar zxf /app/omada/data-html.tar.gz -C /config/data`; `mkdir -p /config/data/{pdf,db,keystore}`.
2. Symlink runtime dirs (create when missing, fix wrong links, as `apps/unifi-network-application/start.sh` does): `/app/omada/data` and `/app/omada/logs` cannot be created in read-only `/app`, so create the links at build time pointing to `/config/data`, `/config/logs`, and `/config/properties` (broken until the volume is seeded). `work/` → `/tmp/omada-work` (README says unused since 5.0.x).
3. Apply port env vars with `sed` on `/config/properties/omada.properties` only when the key exists and the value differs (`manage.https.port`, etc.), as upstream does. Values are validated numeric (no special characters reach sed).
4. Embedded MongoDB: start `mongod --bind_ip 127.0.0.1 --port 27217 --dbpath /config/data/db --logpath /config/logs/mongod.log --fork`-style is not allowed (no daemon); run it as a background job from `start.sh`, wait for the port, and stop it on exit with a `trap` on TERM/INT (UNVERIFIED how Omada itself launches mongod: `bin/mongod` wrapper vs. external). If `MONGO_EXTERNAL=true` and `EAP_MONGOD_URI` are set, skip the embedded start and apply them to `omada.properties`; URI contains a password, so write it only to the properties file in `/config` (mode 600), never to argv.
5. TLS: if `/cert/${SSL_CERT_NAME}` and key exist, build the keystore as upstream (optional, may be deferred; mark in PR).
6. Final: `cd /app/omada/lib && exec java -server -Xms${JAVA_MIN_HEAP_SIZE:-128}m -Xmx${JAVA_MAX_HEAP_SIZE:-1024}m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/config/logs/java_heapdump.hprof -Djava.awt.headless=true -cp "/app/omada/lib/*:/config/properties" com.tplink.smb.omada.starter.OmadaLinuxMain` (heap env values given in MB; upstream treats them like `-Xmx` arguments, confirm format UNVERIFIED). Listens on all interfaces by default (UNVERIFIED, confirm with `ss -ltn`). Because `exec java` is PID 1 while mongod is a background child, mongod must be reaped; if Omada can launch its own mongod, use that path instead.

Idempotent: nothing is overwritten once present in `/config`. Never writes to `/app`; `/tmp` for scratch.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '8043'
- port: '8088'
- port: '8843'
- port: '8044'
- port: '29811'
- port: '29812'
- port: '29813'
- port: '29814'
- port: '29815'
- port: '29816'
- port: '29817'
filePaths:
- /app/omada/lib
- /usr/local/bin/mongod
- /usr/share/licenses/mongodb/LICENSE-Community.txt
- /start.sh
```
Every TCP port in settings.yaml has a probe; the UDP ports are intentionally not probed (see section 6). Whether the controller actually opens all of 8843/8044/2981x on first start is UNVERIFIED (some bind only after the first-run wizard); if any is not open, drop it from both `settings.yaml` and the test, never from the test alone. `timeoutSeconds: 300` because the Java controller plus MongoDB start slowly (siblings use 180 to 240). No DB-narrowing exception (database is embedded).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/opt/tplink/EAPController/data` (incl. `db`, `html`, `pdf`, `keystore`, `LAST_RAN_OMADA_VER.txt`) | `/config/data`, link created at build |
| `/opt/tplink/EAPController/logs` | `/config/logs` |
| `/opt/tplink/EAPController/properties` (sed-edited, `chmod 777` upstream) | copied to `/config/properties`, classpath points there |
| `/opt/tplink/EAPController/work` | `/tmp/omada-work` |
| mongod dbpath | `/config/data/db`; mongod binds 127.0.0.1:27217 only |
| `PUID/PGID` user creation, `gosu`, `chown` | removed; `ROOTLESS=true`, runs as `apps` (568) |
| `/etc/java-*/security/java.security` TLS 1.0/1.1 re-enable | not supported (upstream disables in rootless too) |
| Draft: UID 0, rootfs writable, pvc `data` and `work` | UID 568, read-only rootfs, single `/config` volume (migrate old `data` into `/config/data`) |
| `application.properties`, `/cert` keystore import | `/config`, optional |

## 10. Risks, caveats and open questions

- Licence and redistribution: TP-Link software is proprietary; shipping it in a public registry may not be allowed (UNVERIFIED). Potential blocker, needs maintainer decision.
- Download URL embeds a date stamp and is resolved by a third-party service (mbentley.net); the `static.tp-link.com` URL must be pinned and may rot. No upstream checksum.
- Draft said `.deb` and MongoDB 27017; reality is a `.tar.gz` and 127.0.0.1:27217.
- Device discovery needs UDP 29810/27001/19810 and the 2981x TCP ports reachable from the LAN: host networking or `macvlan` is normally required (UNVERIFIED for k8s). Devices may also require the "inform URL" to point at the host.
- MongoDB 8.0 is end-of-life later; apps/mongodb is 9.0.4, which Omada may not support (UNVERIFIED).
- Heavy: JRE + MongoDB + controller, 2 GB RAM recommended.
- 6.4 beta changes the upgrade port to 8044; the plan already opens it.
- No arm64 .tar.gz check was made (UNVERIFIED: same archive for both arches); the upstream image is multi-arch.
- UNVERIFIED count: 13 (licence, checksum, arm64 archive, tag filter, mongod launch model, property edit details, heap env format, bind address, extra ports opening on first start, jar version name, tarball licence file, UDP probe support, Mongo 9 compatibility).

## 11. Build and test steps

```sh
cd apps/omada-controller
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create omada-controller-probe-config
docker run --rm -d --name omada-controller-probe --read-only --tmpfs /tmp -v omada-controller-probe-config:/config omada-controller:6.3.0.111
docker logs -f omada-controller-probe     # allow 2-3 minutes
forgetool containers test --image omada-controller:6.3.0.111 --config ./apps/omada-controller/container-test.yaml
docker rm -f omada-controller-probe; docker volume rm omada-controller-probe-config
```
Readiness: `curl -k https://localhost:8043/api/info` returns JSON (upstream healthcheck), logs show the controller server started with no repeated stack traces, `mongod` accepting connections on 127.0.0.1:27217, and the container stays up. Repeat on a restart with the same volume to prove idempotency, then once on arm64 if hardware is available. Round limit 10, clean up between rounds.

## 12. PR checklist

- Branch `feat/add-omada-controller`; commit and PR title `feat(omada-controller): add new container`; target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md` (keep sections, tick only applicable boxes); include source, version, base `java17`, embedded MongoDB version, ports/volumes; `🤖 This PR is AI generated.` in Notes.
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Untested at plan time: everything runtime (build, rootless start, controller readiness, device adoption, arm64, TLS keystore import, MongoDB 8.0 vs 9.0 compatibility) and the redistribution licence. State this in the PR; do not check "Built container locally" unless done.
