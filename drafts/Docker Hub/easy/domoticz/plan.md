# domoticz — implementation plan
> Source: ./draft.md · Target: apps/domoticz/ · Difficulty: easy (medium for hardware plugins) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `2026.4` (latest release, published 2026-10-01, no `v` prefix). Same as the draft. |
| Renovate | `datasource=github-releases depName=domoticz/domoticz versioning=loose` (calendar versions like `2026.4`) |
| License | GPL-3.0. `License.txt` in the tarball is "GNU GENERAL PUBLIC LICENSE Version 3". Whether "or later" applies is UNVERIFIED (source headers not checked); use `GPL-3.0-only` unless the headers say "or any later version". GitHub reports SPDX `GPL-3.0`. |
| Source | https://github.com/domoticz/domoticz |
| amd64 URL | `https://github.com/domoticz/domoticz/releases/download/2026.4/domoticz_linux_x86_64.tgz` |
| arm64 URL | `https://github.com/domoticz/domoticz/releases/download/2026.4/domoticz_linux_aarch64.tgz` |
| Checksums | Release assets `domoticz_linux_x86_64.tgz.sha256sum` and `domoticz_linux_aarch64.tgz.sha256sum`. The file format is `<sha256>  update.tgz` (file name inside is not the asset name), so verify with the first field only. amd64 `47b110bb028d3fa5e15dd107965687a2d020159bc821be5920602e69e5328acc` (matches my own `sha256sum`), arm64 `c7bffff723f2b0c81fcebfd803dfb61ebcf6db06442e93ae36085f2e83f25184`. |
| Tarball content (x86_64) | flat, no top-level dir: `domoticz` (binary), `domoticz.sh`, `History.txt`, `License.txt`, `Config/` (OpenZWave configs), `dzVents/`, `plugins/`, `scripts/`, `www/`, `server_cert.pem`, `updatebeta`, `updaterelease` |
| Binary needs (readelf `NEEDED`) | libsqlite3.so.0, libssl.so.3, libcrypto.so.3, libusb-0.1.so.4, libz.so.1, libresolv, libcurl-gnutls.so.4, libmosquitto.so.1, libm, libc. Highest glibc symbol `GLIBC_2.36`, fine on Ubuntu 26.04. No libpython in `NEEDED` (Python plugins load it dynamically; UNVERIFIED). |
| Ubuntu 26.04 (resolute) packages | `libusb-0.1-4`, `libcurl3t64-gnutls`, `libmosquitto1`, `libsqlite3-0` all exist (packages.ubuntu.com). `libssl3` and `zlib1g` are in the ubuntu base already (base installs `libssl3`; zlib UNVERIFIED, check with `dpkg -l`). |
| Upstream Dockerfile | Reviewed (`domoticz/domoticz-docker`): debian trixie-slim, apt `ca-certificates libc-bin tzdata rsync unzip less vim git jq libmosquitto1 libudev1 libusb-0.1-4 libsqlite3-0 curl libcurl4-gnutls-dev libpython3.13-dev`, tarball unpacked into `/opt/domoticz`, `mkdir /opt/domoticz/userdata`, `VOLUME /opt/domoticz/userdata`, `EXPOSE 8080 443`, env `LOG_PATH`, `DATABASE_PATH`, `WWW_PORT=8080`, `SSL_PORT=443`, `EXTRA_CMD_ARG`, `TZ=Europe/Amsterdam`, a Python venv (`pyserial`, `requests`, ...) for plugins. Note: upstream downloads from `releases.domoticz.com`, we use the GitHub release asset instead (same tarball name). |
| Upstream entrypoint | Runs `domoticz -www $WWW_PORT -noupdates -sslwww $SSL_PORT -userdata /opt/domoticz/userdata [-log $LOG_PATH] [-dbase $DATABASE_PATH] $EXTRA_CMD_ARG`. First it rsyncs from the app tree into the userdata dir with `--ignore-existing`: `plugins/examples`, bundled plugins, `customstart.sh`, `www/templates`, `scripts/dzVents/examples`. |
| CLI (from `main/domoticz.cpp` on master) | `-www <port>`, `-sslwww <port>` (accepted range 0..49151, so 0 is accepted; documented meaning of 0 as "disabled" UNVERIFIED), `-wwwbind <addr>` (default `0.0.0.0`), `-userdata <dir>`, `-dbase <file>`, `-noupdates`, `-log <file>`, `-loglevel`, `-approot <dir>`, `-wwwroot <dir>`, `-nowwwpwd`, `-startupdelay`. |

## 2. Target layout

```
apps/domoticz/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` is needed: the tree under `/app` is the seed source and `start.sh` copies from it. Never `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```

Prebuilt C++ binary on glibc, so the plain ubuntu base. Closest sibling: `apps/adguardhome-sync` for tarball handling; `apps/nzbhydra2` for a web UI with a config dir in `/config`.

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`, `ARG TARGETARCH`; `USER root`; `ENV HOME=/config TZ=Etc/UTC`.
2. `apt-get update && apt-get install -y --no-install-recommends libusb-0.1-4 libcurl3t64-gnutls libmosquitto1 libsqlite3-0 zlib1g && rm -rf /var/lib/apt/lists/*`. These are runtime libraries, not the app, so no version pin (the app version comes from the tarball). Drop any package `dpkg -l` shows as already present. Optional (plugins, UNVERIFIED need): `libudev1`; hold back python for now (see section 10).
3. Arch mapping then download and verify in one `RUN`:
   - `case "${TARGETARCH}" in amd64) A=x86_64;; arm64) A=aarch64;; *) exit 1;; esac`
   - `curl -fsSL -o /tmp/domoticz.tgz "https://github.com/domoticz/domoticz/releases/download/${VERSION}/domoticz_linux_${A}.tgz"`
   - `curl -fsSL -o /tmp/domoticz.sha256 "https://github.com/domoticz/domoticz/releases/download/${VERSION}/domoticz_linux_${A}.tgz.sha256sum"`; verify with `echo "$(awk '{print $1}' /tmp/domoticz.sha256)  /tmp/domoticz.tgz" | sha256sum -c -`.
   - `tar xzf /tmp/domoticz.tgz -C /app` (flat archive, so everything lands in `/app`).
4. Licenses: `mkdir -p /usr/share/licenses/domoticz && cp /app/License.txt /usr/share/licenses/domoticz/` (all files are installed, but the standard path keeps it consistent).
5. `chown -R apps:apps /app && chmod -R 755 /app && chmod 755 /app/domoticz`; `rm -f /tmp/domoticz.*`; `/app/domoticz -version` is not verified, skip or check in the run.
6. `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 8080`; `VOLUME /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "domoticz" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=domoticz/domoticz versioning=loose
  default = "2026.4"
}
variable "LICENSE" { default = "GPL-3.0-only" }   # see section 1 for the open point
variable "SOURCE"  { default = "https://github.com/domoticz/domoticz" }
```

Standard `docker-metadata-action`, `group "default"`, `image`, `image-local`, `image-all` (amd64, arm64) blocks from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/domoticz/domoticz"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: WWW_PORT
    default: "8080"
    required: false
  - name: SSL_PORT
    default: "0"        # HTTPS off by default; upstream image default is 443
    required: false
  - name: DATABASE_PATH
    default: "/config/domoticz.db"
    required: false
  - name: LOG_PATH
    default: ""         # empty = log to stdout
    required: false
  - name: EXTRA_CMD_ARG
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

These names are the ones upstream's entrypoint reads; `start.sh` below implements the same semantics so they are not silently ignored. No dependencies.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

USERDATA=/config
mkdir -p "${USERDATA}"

# seed bundled content into the writable userdata only when missing (idempotent, never overwrite edits)
seed() { # $1 source under /app, $2 destination under userdata
  [ -e "$2" ] || { mkdir -p "$(dirname "$2")"; cp -r "$1" "$2"; }
}
seed /app/plugins/examples          "${USERDATA}/plugins/examples"
seed /app/www/templates             "${USERDATA}/www/templates"
seed /app/scripts/dzVents/examples  "${USERDATA}/scripts/dzVents/examples"

ARGS=(-www "${WWW_PORT:-8080}" -sslwww "${SSL_PORT:-0}" -noupdates -userdata "${USERDATA}/" \
      -dbase "${DATABASE_PATH:-/config/domoticz.db}")
[ -n "${LOG_PATH:-}" ] && ARGS+=(-log "${LOG_PATH}")

cd /app
# EXTRA_CMD_ARG is split on whitespace on purpose (flags), never evaluated by a shell
# shellcheck disable=SC2206
exec /app/domoticz "${ARGS[@]}" ${EXTRA_CMD_ARG:-}
```

Notes: `-wwwbind` already defaults to `0.0.0.0`, so the web UI is reachable from other containers (verify with a request from outside). Bundled plugins other than `examples` (upstream also syncs them): copy each missing directory under `/app/plugins/*/` the same way, in a small loop. UNVERIFIED which of `plugins/`, `scripts/` and `www/templates` Domoticz expects under `-userdata` versus `-approot`; the upstream entrypoint copies them there, so mirror it and check the log for "file not found" lines. Upstream's `customstart.sh` and Python venv are left out (see section 10).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/domoticz
- /app/www
- /usr/share/licenses/domoticz/License.txt
```

Port 8080 in `settings.yaml` has a probe. The test needs no env (defaults suffice); SSL stays off. Not DB-dependent (SQLite), so no narrowing. Take `timeoutSeconds` from a sibling web-UI app (180 as in `apps/babybuddy`); first start creates the database.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `/opt/domoticz/userdata` (database, backups, scripts, plugins, templates, log) | `/config` (`-userdata /config/`, `-dbase /config/domoticz.db`) |
| First-run marker `/opt/domoticz/FIRSTRUN` | Not needed (our seeding is per-file and idempotent) |
| `chown -R 1000:1000 userdata` in upstream entrypoint | Not used; image runs as `apps` (568) and `/config` is writable by it |
| Writes inside the app dir (`domoticz.log`, temp files) | Logging defaults to stdout; temp files UNVERIFIED, if the read-only run shows writes into `/app`, set `-approot /app` and point them to `/tmp` |
| `server_cert.pem` self-signed cert in the app dir | Read only, unused while `-sslwww 0` |

Draft/chart expectations: UID 0, writable rootfs, data in `/opt/domoticz/userdata`. This image uses UID 568, read-only rootfs and `/config`; migrating users move `userdata` to `/config`. Not privileged. Hardware access (USB, serial, Z-Wave dongles) needs device mounts and group membership (the ubuntu base adds `apps` to groups 20 and 44, which cover `dialout`/`video` on Debian-style systems; verify `dialout`, UNVERIFIED).

## 10. Risks, caveats and open questions

- Python plugins and dzVents: upstream bundles a venv and `libpython3.13-dev`. The binary does not link libpython, so Python plugin support is UNVERIFIED here; first release can ship without it and document that. If wanted, either base the app on `ghcr.io/trueforge-org/python` or install the matching system python, a decision for the maintainer.
- Z-Wave/serial/USB: not passed through by default (draft caveat); needs device mounts in the deployment.
- First start shows a setup in the web UI; with no password set the UI is open to anyone who reaches port 8080. Same as upstream defaults.
- HTTPS disabled by default (`SSL_PORT=0`); users who want it set `SSL_PORT` and add a port entry or terminate TLS at a proxy.
- `-sslwww 0` behavior is based on the parser accepting 0; confirm in the run that no listener appears on 443/other.
- Licence variant (only/or-later) needs confirming.
- `-noupdates` stops the self-updater, which would otherwise try to write to `/app`.

## 11. Build and test steps

```sh
cd apps/domoticz
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name domoticz-probe --read-only --tmpfs /tmp -v domoticz-probe-config:/config -p 8080:8080 domoticz:2026.4
docker logs -f domoticz-probe        # expect "Domoticz V... (c)" start-up lines and "Webserver started on 0.0.0.0:8080" (UNVERIFIED wording)
curl -fsS http://127.0.0.1:8080/json.htm?type=command\&param=getversion
forgetool containers test --image domoticz:2026.4 --config ./apps/domoticz/container-test.yaml
docker rm -f domoticz-probe; docker volume rm domoticz-probe-config
```

Confirm `/config/domoticz.db` is created, nothing errors about missing `www/templates` or plugins, and a restart on the same volume keeps data.

## 12. PR checklist

- Branch `feat/add-domoticz`; commit `feat(domoticz): add new container`; target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; tick only the boxes that apply; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign; `license/cla` shows status).
- Untested until run: arm64, Python plugins, dzVents, USB/serial/Z-Wave hardware, HTTPS, MQTT.
- Pre-completion: `bake --print` passes, VERSION aligned in Dockerfile and bake, empty `/config` works, no `DOWNSTREAM_CHANGES.md`.
