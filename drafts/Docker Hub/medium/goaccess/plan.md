# goaccess — implementation plan
> Source: ./draft.md · Target: apps/goaccess/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v1.12` (GitHub release 2026-09-16, latest in the feed). Previous: v1.11 (2026-07-20), v1.10.2 (2026-04-01). `configure.ac` on master confirms 1.12. |
| Renovate | `// renovate: datasource=github-releases depName=allinurl/goaccess versioning=loose`. `loose` because the tag `v1.12` is two-part, not strict semver. |
| License | MIT (`COPYING`: "The MIT License (MIT), Copyright 2009-2022 Gerardo Orellana", on master). The tag `v1.12` copy is UNVERIFIED. |
| Source URL | https://github.com/allinurl/goaccess |
| Download | Binary: `apt:goaccess` (Ubuntu package). Source fallback: the v1.12 tag source (release page confirmed; tarball URL is standard GitHub, not fetched). |
| Checksum source | apt: the package signature chain of the Ubuntu archive. Source: none found (UNVERIFIED). |
| Ubuntu package | `goaccess` exists in Ubuntu noble (packages.ubuntu.com). Its version in the 26.04 archive is UNVERIFIED (the package page was not fully fetched). |
| Upstream Dockerfile reviewed | `https://raw.githubusercontent.com/gregyankovoy/docker-goaccess/efd688be8b6ae2991209e76de4908860a3350297/Dockerfile`. Base `gregyankovoy/alpine-base` (Alpine, musl). Builds goaccess **v1.4** from `https://github.com/allinurl/goaccess/archive/v1.4.tar.gz` with `--enable-utf8 --enable-geoip=mmdb`. Runtime: nginx, tini, ncurses, libintl, libmaxminddb. A GeoLite city DB comes from a build arg (upstream URL UNVERIFIED). `COPY /root /.`, `goaccess.sh` executable, `chmod -R 777 /var/tmp/nginx`, `EXPOSE 7889`, `VOLUME ["/config", "/opt/log"]`, `CMD sh /usr/local/bin/goaccess.sh`, no `USER` (root). |
| `goaccess.sh` | Not fetched (UNVERIFIED). It starts nginx and goaccess under tini. Flags and the WebSocket port are UNVERIFIED. |
| Env vars (upstream) | None found in the Dockerfile. |
| Port | `7889` (upstream `EXPOSE 7889`, chart service port 7889). The draft's `7890` is not in upstream. The WebSocket port is UNVERIFIED (see section 7). |
| Write paths | Upstream: `/config` (VOLUME, reports and config), `/var/tmp/nginx` (nginx temp, chmod 777), `/opt/log` (log input, chart mount). |
| Docker Hub tags | `latest` (`sha256:157fc99be09f0b0d680ed0f7be716c81288ea9fe40a4435fab05356b35121421`, amd64 only, pushed 2020-10-02) and `1.4` (2020-08-20). Stale and amd64 only. |
| Chart | `charts/stable/goaccess`. Values pin `latest@sha256:157fc99...`. Persistence `goaccess` at `/opt/log`. Service port 7889. `readOnlyRootFilesystem: false`, `runAsUser 0`, `runAsGroup 0`. |
| copy-from | `no` for amd64 and arm64: the image is an Alpine/musl build and amd64 only. We do not copy from it. |

## 2. Target layout

- `apps/goaccess/Dockerfile`
- `apps/goaccess/docker-bake.hcl`
- `apps/goaccess/settings.yaml`
- `apps/goaccess/container-test.yaml`
- `apps/goaccess/start.sh`: copied to `/start.sh`. It runs goaccess and the report server (section 7).
- A static report template or nginx config under `etc/` only if the nginx route needs a file to ship (UNVERIFIED, decide with section 7). `etc/` is in the `.dockerignore` allow-list.

No `defaults/`, no `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Recommended: `FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`.

Why: the report is an HTML page served by a web server. `apps/nginx/Dockerfile` already provides nginx on the same ubuntu base (`ghcr.io/trueforge-org/ubuntu:26.4@sha256:19cb2ce...`), so nginx does not need to be installed again. goaccess is then the only package added with apt.

Alternative (the draft's first choice): `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, with goaccess from apt and nginx from apt (adds a package install and is the route that needs a supervisor either way). Pick one before the first build. Closest siblings: `apps/nginx` and `apps/it-tools` (nginx-based).

## 4. Dockerfile

1. `ARG VERSION` (must equal bake VERSION, `v1.12`) and `ARG TARGETARCH`. Only the apt package version is pinned here.
2. `USER root`.
3. Install goaccess, pinned to the Ubuntu version that matches 1.12. Check the version in the archive first (UNVERIFIED):

```dockerfile
RUN apt-get update && \
    apt-cache policy goaccess && \
    apt-get install -y --no-install-recommends goaccess=<ubuntu-version> && \
    rm -rf /var/lib/apt/lists/*
```

   Replace `<ubuntu-version>` with the exact string from `apt-cache policy`. If the archive version is not 1.12 (or not the newest 1.x), use the fallback: build goaccess 1.12 from the tag source (autotools, configure flags UNVERIFIED for 1.12; the draft and upstream used `--enable-utf8 --enable-geoip=mmdb`, and GeoIP is optional). Do not keep the upstream v1.4 build.
4. License: `mkdir -p /usr/share/licenses/goaccess && cp /usr/share/doc/goaccess/copyright /usr/share/licenses/goaccess/LICENSE` if the Ubuntu copyright file carries the MIT text (UNVERIFIED). Otherwise fetch `COPYING` from `https://raw.githubusercontent.com/allinurl/goaccess/v1.12/COPYING` at build time.
5. Writable paths for nginx on a read-only rootfs: point the temp and cache paths at `/tmp` in the nginx config (`client_body_temp_path`, `proxy_temp_path`, `fastcgi_temp_path`, `uwsgi_temp_path`, `scgi_temp_path`) and the pid file, instead of upstream `/var/tmp/nginx`. The nginx base's own paths are UNVERIFIED: check `apps/nginx` before writing the config.
6. Tail:

```dockerfile
ENV HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 7889
VOLUME ["/config"]
WORKDIR /config
```

`VOLUME /opt/log` from upstream is not carried over. The log folder is a read-only mount added by the user (listed in `settings.yaml` as an optional volume, section 6).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "goaccess"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=allinurl/goaccess versioning=loose
  default = "v1.12"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/allinurl/goaccess"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

Validate with `docker buildx bake --print` from `apps/goaccess`. The `VERSION` value is `v1.12`, and the apt pin in the Dockerfile is the Ubuntu version string, which is different on purpose (the Dockerfile comment must say which Ubuntu version is pinned).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/allinurl/goaccess"
ports:
  - port: 7889
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /opt/log
    required: false
dependencies: []
```

- Port 7889 only, matching the upstream `EXPOSE` and the chart service. Add a WebSocket port only after `goaccess.sh` is read (UNVERIFIED).
- `/opt/log` is a read-only input (the access logs from the web server). Listed as optional because it is a mount the user provides.
- No env vars: the upstream image reads none, and no other env is confirmed.
- Dependencies: none. The nginx base is a build-time `FROM`, not a runtime dependency.

## 7. start.sh

Upstream `goaccess.sh` was not fetched, so the exact commands are UNVERIFIED. The skeleton below is the design; fill in the flags after reading `goaccess.sh` at the pinned upstream commit.

```bash
#!/usr/bin/env bash

mkdir -p /config/report

LOG=/opt/log/access.log   # UNVERIFIED path and format; the chart mounts /opt/log

if [[ ! -r "${LOG}" ]]; then
    echo "No readable log at ${LOG}; waiting for one"
    # keep the process alive; see the caveat in section 10
fi

# goaccess writes the HTML report into /config (persistent) or /tmp (ephemeral)
goaccess "${LOG}" --log-format=COMBINED -o /config/report/index.html   # flags UNVERIFIED

exec nginx -g 'daemon off;'
```

- The process model must keep both goaccess and nginx alive, or let one process own the port. Upstream uses tini to run two processes. Two options: (a) goaccess real-time mode with its built-in WebSocket server plus nginx for the HTML (needs two processes, so a tiny supervisor such as `wait -n`, UNVERIFIED for this image); (b) a static report regenerated on start, served by nginx, which needs one process per restart (simplest, no live updates). Pick (a) or (b) after reading `goaccess.sh`, and record the choice in the PR.
- `exec` for the last long-running process. Do not `exec` goaccess if nginx is needed.
- Idempotent: `mkdir -p` only. Reports go to `/config/report` (persistent) or `/tmp` (ephemeral, the protocol default for caches).
- No writes to `/app`.
- Bind: nginx and any goaccess socket listen on `0.0.0.0` (the port must be reachable from other containers, UNVERIFIED for the real-time server).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '7889'
http:
- port: '7889'
  path: /
filePaths:
- /usr/bin/goaccess
- /usr/share/licenses/goaccess/LICENSE
```

- The test runs with no `/opt/log` mount. If the start script exits when the log is missing, the run fails the "still running" criterion. The start script must keep running without a log (section 7), and the probes above check that it does.
- The `http` probe at `/` needs the report to exist. If the report is generated only when a log exists, `/` may return 404 with no log. Either create an empty report at start, or change the probe to the nginx status page (UNVERIFIED for the nginx base). Do not weaken the probe: pick the behavior that is correct for users.
- `timeoutSeconds: 120` matches the lighter siblings. Raise it if the start is slow.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (VOLUME, upstream root) | `/config` (persistent, owned by `apps`). The report goes to `/config/report`. |
| `/var/tmp/nginx` (chmod 777, upstream) | `/tmp` in the nginx config (section 4 step 5). |
| `/opt/log` (chart PVC, read by root upstream) | Read-only mount. Non-root `apps` must be able to read the file. Ownership is a caveat (section 10). |
| nginx pid and cache | `/tmp` (UNVERIFIED which paths the nginx base uses). |

Draft expectations reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem: false`. Our image runs as `apps` (568). The log file must be readable by that UID. Not privileged.

## 10. Risks, caveats and open questions

- Upstream is stale (2020, goaccess 1.4 on Alpine). The new image uses apt goaccess (Ubuntu version UNVERIFIED) or a 1.12 source build. Do not copy the upstream binary (musl, amd64 only).
- Log access: the chart mounts `/opt/log` and upstream runs as root. Our `apps` user may not read the host log (file mode and owner). Document in the PR, and let the user set the log permissions or a group.
- No log, no report: the start script must not exit when the log is missing (section 7, section 8).
- Two processes (nginx and goaccess) need a small supervisor or a single-owner design (section 7). Exact behavior UNVERIFIED until `goaccess.sh` is read.
- WebSocket (real-time) port: the draft's `7890` is not confirmed upstream. The chart uses `7889`. If real-time needs a second port, add it to `settings.yaml` and to `container-test.yaml` (every port needs a probe).
- The apt goaccess version may be older than 1.12 in the Ubuntu archive (UNVERIFIED). If so, use the source build (section 4 step 3 fallback).
- arm64: the apt package is arch-neutral for amd64 and arm64 on Ubuntu (general behavior, not confirmed for arm64 specifically; UNVERIFIED).
- No blockers: not musl-only, no GPU, not privileged, no database.

## 11. Build and test steps

```sh
cd /workspaces/containers/apps/goaccess
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name goaccess-probe --read-only --tmpfs /tmp \
  -v goaccess-probe-config:/config goaccess:v1.12
docker logs -f goaccess-probe
forgetool containers test --image goaccess:v1.12 --config ./apps/goaccess/container-test.yaml
docker rm -f goaccess-probe; docker volume rm goaccess-probe-config
```

Readiness signals (UNVERIFIED wording, check the first real run): `goaccess` reports the version (1.12) and the nginx line `start worker process` (or the built-in ready line). Also run once with a sample access log mounted read-only at `/opt/log` and confirm `/config/report` is written, then run once with no log to confirm the container still runs. Run with `-p 7889:7889` and curl from the host to prove the port is not bound to localhost.

## 12. PR checklist

- Branch `feat/add-goaccess`, commit `feat(goaccess): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Untested to state honestly: the `goaccess.sh` behavior (not read), the real-time WebSocket, the log permissions for non-root `apps`, the arm64 build, and the read-only run with a real log.
- Before the commit: `docker buildx bake --print` passes, `VERSION` in bake equals the version used in the build, the apt version pin is recorded, and no assertion was weakened.
