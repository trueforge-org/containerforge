# modsecurity-crs — implementation plan
> Source: ./draft.md · Target: apps/modsecurity-crs/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | OWASP CRS `4.31.0` (latest release, published 2026-11-23). Draft/chart image pin is `owasp/modsecurity-crs:3.3.4-apache-202307110507` (last pushed 2023-07-11, stale). This plan pins CRS `4.31.0`; the image version is not reused. |
| Renovate | `datasource=github-releases depName=coreruleset/coreruleset versioning=semver` (suggested; repo renovate config and annotation style not checked, UNVERIFIED) |
| License | Apache-2.0 for CRS (GitHub SPDX). ModSecurity engine license from the apt package: UNVERIFIED. |
| Source URL | https://github.com/coreruleset/coreruleset |
| Download (CRS) | `https://github.com/coreruleset/coreruleset/archive/refs/tags/v${VERSION}.tar.gz` (tag `v4.31.0`). Upstream image uses the same tarball plus `.asc`. Exact asset URL for 4.31.0 not re-fetched (UNVERIFIED). |
| Download (ModSecurity engine) | apt `libapache2-mod-security2` on Ubuntu 26.04. Version and arm64 availability: UNVERIFIED (not checked). |
| Per-arch | CRS is interpreted rules, identical on amd64 and arm64. Apache and ModSecurity come from apt per architecture (UNVERIFIED for arm64 package). |
| Checksum source | CRS: GPG signature `.asc` verified against https://coreruleset.org/security.asc (as upstream `apache/Dockerfile` does). ModSecurity: apt signature (automatic). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/coreruleset/modsecurity-crs-docker/0148a7443cfa92c9d229b546c89378f548f45410/apache/Dockerfile (base `httpd:2.4.57`, compiles ModSecurity 2.9.7 from source, downloads CRS tarball, `/docker-entrypoint.sh`, `HEALTHCHECK` `/usr/local/bin/healthcheck`, `CMD httpd-foreground`). Entrypoint script itself not fetched (UNVERIFIED). |
| Ports | 80 (`PORT`) and 443 (`SSL_PORT`), from upstream Dockerfile. |
| Env vars (real, upstream Dockerfile) | `PORT=80`, `SSL_PORT=443`, `SERVER_NAME`, `SERVER_ADMIN`, `BACKEND=http://localhost:80`, `BACKEND_WS`, `PROXY_SSL`, `PROXY_SSL_VERIFY`, `PROXY_PRESERVE_HOST`, `PROXY_TIMEOUT`, `PROXY_ERROR_OVERRIDE`, `REMOTEIP_INT_PROXY`, `REQ_HEADER_FORWARDED_PROTO`, `SSL_ENGINE`, `SSL_PROTOCOL`, `SSL_CIPHER_SUITE`, `SSL_USE_STAPLING`, `SSL_SESSION_TICKETS`, `SSL_HONOR_CIPHER_ORDER`, `LOGLEVEL=warn`, `ACCESSLOG`, `ERRORLOG`, `METRICS_*`, `WORKER_CONNECTIONS=400`, `TIMEOUT=60`, `H2_PROTOCOLS`, `MODSEC_RULE_ENGINE=on`, `MODSEC_REQ_BODY_ACCESS=on`, `MODSEC_REQ_BODY_LIMIT=13107200`, `MODSEC_REQ_BODY_LIMIT_ACTION=Reject`, `MODSEC_RESP_BODY_ACCESS=on`, `MODSEC_RESP_BODY_LIMIT=1048576`, `MODSEC_AUDIT_ENGINE=RelevantOnly`, `MODSEC_AUDIT_LOG=/dev/stdout`, `MODSEC_AUDIT_LOG_FORMAT=JSON`, `MODSEC_AUDIT_LOG_TYPE=Serial`, `MODSEC_AUDIT_STORAGE`, `MODSEC_STATUS_ENGINE=Off`, `MODSEC_TMP_SAVE_UPLOADED_FILES=on`, `MODSEC_TAG`, `PARANOIA=1`, `ANOMALY_INBOUND=5`, `ANOMALY_OUTBOUND=4`, `BLOCKING_PARANOIA=1`. Only the subset this app implements goes into `settings.yaml` (see section 6). |
| Write paths (upstream) | `/tmp/modsecurity/{data,upload,tmp}`, `/var/log/apache2/`, `/var/log/modsecurity/audit/`, `/etc/modsecurity.d/` (symlink to `/opt/owasp-crs`). No `VOLUME` in the upstream Dockerfile. The draft's `/modsecurity/data`, `/modsecurity/temp`, `/modsecurity/upload` paths are not what the image uses. |
| User | Upstream has no `USER` line; `USER=www-data` env, runs as root unless the entrypoint drops privileges (UNVERIFIED). |
| Dependencies | None (no database). |

## 2. Target layout

- `apps/modsecurity-crs/Dockerfile`
- `apps/modsecurity-crs/docker-bake.hcl`
- `apps/modsecurity-crs/settings.yaml`
- `apps/modsecurity-crs/container-test.yaml`
- `apps/modsecurity-crs/start.sh` (renders the Apache config from env, seeds `/config`, then `exec`s `httpd`)
- `apps/modsecurity-crs/etc/apache2/` (a small Apache config: listen port, PID and lock paths under `/tmp`, module loads, `IncludeOptional /config/...`). `etc/` is on the `.dockerignore` allow-list. Reason: the packaged `apache2.conf` writes its PID and lock under `/run` and runs as `www-data`, neither of which works rootless with `--read-only`.
- `apps/modsecurity-crs/defaults/config/crs-setup.conf` (seed copy, copied to `/config` only when missing). Reason: the user-tunable CRS settings must live in `/config`, not `/app`.

No `root/` (never used). No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base; checked: no `FROM` on this image in the repo).

## 3. Base image

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```

Fits because Apache and ModSecurity are available from the Ubuntu archive, so no compile is needed, and the base already provides curl and tar. No Apache base exists in ContainerForge. Closest siblings: `apps/adguardhome-sync` (ubuntu layout, `VOLUME /config`, `USER apps`) and `apps/valkey` (pinned apt packages, `health/` dir, `start.sh` that `exec`s the server). Single stage is enough: CRS is downloaded and verified in the same stage.

## 4. Dockerfile

1. `ARG VERSION` (CRS, `4.31.0`), `ARG TARGETARCH`, `ARG APACHE_PACKAGE_VERSION` and `ARG MODSEC_PACKAGE_VERSION` (pinned apt versions, UNVERIFIED values; choose the Ubuntu 26.04 versions when implementing).
2. `USER root`.
3. Install with pinned version, no recommends:
   ```dockerfile
   RUN apt-get update && \
       apt-get install -y --no-install-recommends \
         apache2="${APACHE_PACKAGE_VERSION}" \
         libapache2-mod-security2="${MODSEC_PACKAGE_VERSION}" \
         gnupg curl ca-certificates && \
       rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
   ```
   The apt packages are the engine, not the CRS app, so `VERSION` alignment does not apply to them. Pin them anyway, as `apps/valkey` does. Check that `gnupg` is not already in the base first.
4. Enable modules at build time (root): `a2enmod proxy proxy_http headers remoteip unique_id security2` (module list UNVERIFIED against the Ubuntu package).
5. Fetch CRS, verify, unpack to `/app/owasp-crs`:
   ```sh
   curl -fsSL -o /tmp/crs.tar.gz "https://github.com/coreruleset/coreruleset/archive/refs/tags/v${VERSION}.tar.gz"
   curl -fsSL -o /tmp/crs.tar.gz.asc "https://github.com/coreruleset/coreruleset/archive/refs/tags/v${VERSION}.tar.gz.asc"  # UNVERIFIED: asset exists for 4.31.0
   curl -fsSL -o /tmp/security.asc https://coreruleset.org/security.asc
   gpg --import /tmp/security.asc && gpg --verify /tmp/crs.tar.gz.asc /tmp/crs.tar.gz
   mkdir -p /app/owasp-crs && tar xzf /tmp/crs.tar.gz -C /app/owasp-crs --strip-components=1
   ```
   Use `GNUPGHOME=/tmp/gnupg` so no key is written under `/root`. Copy `crs-setup.conf.example` to the seed file, and ship CRS `LICENSE` to `/usr/share/licenses/modsecurity-crs/LICENSE`.
6. `chown -R apps:apps /app` and `chmod -R 755 /app`, as `adguardhome-sync` does.
7. Remove the packaged `/etc/apache2/apache2.conf` and `/etc/apache2/sites-enabled/*` defaults and copy the `etc/` tree in the final `COPY`, so the repo config wins. Keep `/etc/modsecurity/` from the package for `modsecurity.conf-recommended` and `unicode.mapping`.
8. `ENV HOME=/config TZ=Etc/UTC`. Set `MODSEC_TMP_DIR`, `MODSEC_DATA_DIR`, `MODSEC_UPLOAD_DIR` to `/tmp/modsecurity/...` in `start.sh` (not in the image).
9. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8080
   VOLUME /config
   CMD ["/start.sh"]
   ```
   `COPY --chmod=0755 . /` must stay (copies `start.sh`, `etc/`, `defaults/`).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "modsecurity-crs"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=coreruleset/coreruleset versioning=semver
  default = "4.31.0"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/coreruleset/coreruleset"
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

Layout copied from `apps/budge/docker-bake.hcl`. `LICENSE` is the CRS license; the ModSecurity engine license is UNVERIFIED and must be confirmed before merge (rule: `LICENSE` must match the software in the image). Validate with `docker buildx bake --print` from `apps/modsecurity-crs/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/coreruleset/coreruleset"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "8080"
    required: false
  - name: BACKEND
    default: "http://localhost:80"
    required: false
  - name: MODSEC_RULE_ENGINE
    default: "on"
    required: false
  - name: PARANOIA
    default: "1"
    required: false
  - name: BLOCKING_PARANOIA
    default: "1"
    required: false
  - name: ANOMALY_INBOUND
    default: "5"
    required: false
  - name: ANOMALY_OUTBOUND
    default: "4"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Only the subset `start.sh` reads is listed. Other upstream variables (TLS, metrics, audit tuning) are not listed until the implementation reads them. Dependencies: none. Port 8080 instead of upstream 80 is a deliberate rootless change, see section 9.

## 7. start.sh

- `set -euo pipefail`; read the env names above with defaults matching `settings.yaml`.
- Seed `/config/crs-setup.conf` from `/defaults/config/crs-setup.conf` only when missing (`cp -n`).
- Create `/config/rules/` for user exclusions (`REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf`) only when missing.
- Create `/tmp/modsecurity/{data,upload,tmp}` and `/tmp/apache2`, and `mkdir -p /tmp/modsecurity/audit`.
- Render `Listen ${PORT}`, `ProxyPass / ${BACKEND}/` and `SetEnv` for paranoia values into `/tmp/apache2/httpd-rendered.conf` (never under `/app` or `/etc`). Escape values; do not interpolate them into shell commands.
- Apache's `PidFile`, `Mutex` and `DefaultRuntimeDir` point at `/tmp`.
- Log to stdout: `ErrorLog /proc/self/fd/2`, `MODSEC_AUDIT_LOG=/dev/stdout`.
- Final line: `exec httpd -DFOREGROUND -f /tmp/apache2/httpd-rendered.conf`.
- Idempotent: safe with an empty `/config` and on restart; never overwrites an existing `crs-setup.conf`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
filePaths:
- /app/owasp-crs/crs-setup.conf.example
- /app/owasp-crs/rules
- /usr/share/licenses/modsecurity-crs/LICENSE
```

- Every `settings.yaml` port has a `tcp` probe. An `http` probe on `/` is not added: with no backend, the proxy answers 502/503 (PROXY_ERROR_OVERRIDE), so the expected status is UNVERIFIED until run. Add an `http` probe only after the real status is seen in a run.
- `timeoutSeconds: 120` is a guess; check sibling Apache/proxy apps before finalising.
- No required-env code path exists: the image starts with no env vars, so `filePaths` covers the rule files.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Port 80 and 443 (bind below 1024) | Listen on 8080 (`PORT`). Non-root cannot bind 80. Publish 80 with a Docker port mapping, or a Kubernetes Service. TLS on 443 is dropped from the first version (UNVERIFIED that upstream auto-generates certs). |
| `/var/log/apache2/*`, `/var/log/modsecurity/audit/` | Logs to stdout/stderr; audit to `/dev/stdout`. |
| `/tmp/modsecurity/{data,upload,tmp}` | Kept under `/tmp` (ephemeral, as the rules require). |
| `/etc/modsecurity.d/` (symlink to `/opt/owasp-crs`) | Replace with `/app/owasp-crs` (read-only). Rules are not user state. |
| PID, lock, runtime dir (`/run/apache2`) | `/tmp/apache2`. |
| User-tunable CRS settings and exclusions | `/config/crs-setup.conf`, `/config/rules/` (seeded once). |

Expectations reconciled with the draft: the chart forces UID 0 and `readOnlyRootFilesystem: false`. This image runs as `apps` with `USER apps` and must pass `--read-only --tmpfs /tmp`. Not privileged. The draft's extra persistence (`/modsecurity/data`, `/modsecurity/temp`, `/modsecurity/upload`) is replaced by `/tmp` (scratch) and `/config` (user state). Existing chart users with those emptyDir paths lose nothing, because they were scratch.

## 10. Risks, caveats and open questions

- ModSecurity engine: apt package `libapache2-mod-security2` (version, arm64 availability, module name, license) UNVERIFIED. Upstream compiles ModSecurity 2.9.7 from source, so behaviour may differ.
- CRS 4.x needs the matching `crs-setup.conf` layout; the seed file must come from the same tag.
- Port change 80 → 8080 breaks anyone who expects the upstream port; state it in the PR.
- The proxy needs a backend. The default `BACKEND` points at localhost:80, which is not a useful target; the chart sets it per deployment (UNVERIFIED chart value).
- False positives are normal at paranoia 1; users tune exclusions in `/config/rules/`.
- Upstream entrypoint not fetched: how upstream handles `PROXY_SSL`, certificates and `MODSEC_AUDIT_STORAGE` is UNVERIFIED. None of it is implemented in v1.
- No blockers found beyond the unverified apt package details. Not musl-only, no GPU, not privileged, no arm64 issue expected for CRS.

## 11. Build and test steps

```sh
cd apps/modsecurity-crs
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name modsecurity-crs-probe --read-only --tmpfs /tmp \
  -v modsecurity-crs-probe-config:/config modsecurity-crs:4.31.0
docker logs -f modsecurity-crs-probe
forgetool containers test --image modsecurity-crs:4.31.0 --config ./apps/modsecurity-crs/container-test.yaml
docker rm -f modsecurity-crs-probe; docker volume rm modsecurity-crs-probe-config
```

Expected readiness signal: `Starting Apache` / `resuming normal operations` in the Apache log, and no `AH` fatal line. Also check `crs-setup.conf` is seeded into the volume and survives a restart. Test from outside the container (`-p 8080:8080`) to prove Apache listens on all interfaces, not only localhost.

## 12. PR checklist

- Branch `feat/add-modsecurity-crs`, commit and PR title `feat(modsecurity-crs): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only applicable boxes.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: signed Contributor License Agreement required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Say in the PR what was not tested: ModSecurity apt package on arm64, the exact CRS 4.31.0 `.asc` asset, the http probe status, and the port 80 story.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
