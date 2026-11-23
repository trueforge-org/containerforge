# filebrowser — implementation plan
> Source: ./draft.md · Target: apps/filebrowser/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `2.63.23` (release tag `v2.63.23`, "Latest", 27 Jul). Matches the draft. |
| Project status | The README states: "File Browser is archived on 2026-09-01. The last planned release has already shipped. There will be no further releases, bug fixes, or security fixes." Same text on the release page. See section 10. |
| Renovate | `datasource=github-releases depName=filebrowser/filebrowser`, tag has a `v` prefix: add `extractVersion=^v(?<version>.+)$` (as `apps/*` code-server does). It will never produce updates after the archive. |
| License | `Apache-2.0` (header of `LICENSE` at tag `v2.63.23` read: "Apache License Version 2.0"). |
| Source URL | https://github.com/filebrowser/filebrowser |
| Download amd64 | `https://github.com/filebrowser/filebrowser/releases/download/v2.63.23/linux-amd64-filebrowser.tar.gz` |
| Download arm64 | `https://github.com/filebrowser/filebrowser/releases/download/v2.63.23/linux-arm64-filebrowser.tar.gz` (both listed on the release assets page) |
| Checksum source | `https://github.com/filebrowser/filebrowser/releases/download/v2.63.23/filebrowser_2.63.23_checksums.txt` (sha256, `<hash>  <file>` lines). Read: amd64 `b14db2bb8033caa3f80205eb6578b2ed0744ebd9e716b790bc4a9703ce909e88`, arm64 `c55b3450b6ac07ef73b5b49f0b2955a8e755100b71af1df73f9e5d25b12fd27a`. Fetch the file at build time and grep, so a version bump needs no edit. |
| Tarball contents | arm64 tarball listing: `CHANGELOG.md`, `LICENSE`, `README.md`, `filebrowser` (flat, no top directory). amd64 assumed identical; UNVERIFIED. |
| Upstream Dockerfile reviewed | `Dockerfile` on master: final stage `busybox:1.37.0-musl`, `ENV UID=1000 GID=1000`, dirs `/config /database /srv`, `VOLUME /srv /config /database`, `EXPOSE 80`, `ENTRYPOINT tini -- /init.sh`, `HEALTHCHECK /healthcheck.sh`. The binary in the release tarball is a Go binary (musl in the busybox image is only the runtime userland). UNVERIFIED: the binary is statically linked (cgo free); check with `file` after the first build. |
| Upstream defaults | `docker/common/defaults/settings.json` on master: `{"port": 80, "baseURL": "", "address": "", "log": "stdout", "database": "/database/filebrowser.db", "root": "/srv"}`. Upstream `init.sh` copies `/defaults/settings.json` to `/config/settings.json` when missing and execs `filebrowser --config=/config/settings.json "$@"`. |
| Health endpoint | Upstream `healthcheck.sh` does `wget --spider http://$ADDRESS:$PORT/health`, using `FB_PORT` and `FB_ADDRESS` (so those two env vars are real). |
| Other env vars | `FB_PORT`, `FB_ADDRESS` verified (healthcheck). Other `FB_*` names (`FB_DATABASE`, `FB_ROOT`, `FB_CONFIG`) are UNVERIFIED; use CLI flags and the JSON config instead. |
| First-run admin password | Draft says a random admin password is printed in the logs. UNVERIFIED (exact log text not fetched); confirm on first run. |

## 2. Target layout

```
apps/filebrowser/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/settings.json      # seed copied to /config/settings.json when missing
```
`defaults/` is on the `include/.dockerignore` allow-list. Never use `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```
Why: single Go binary on a glibc userland, no extra packages (`curl`, `tar`, `ca-certificates`, `jq` are already in the base). Closest sibling: `apps/adguardhome-sync` (tarball into `/app`, `defaults/` seed, `cp -n` in `start.sh`).

## 4. Dockerfile

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

RUN set -eux; \
    mkdir -p /usr/share/licenses/filebrowser; \
    base="https://github.com/filebrowser/filebrowser/releases/download/v${VERSION}"; \
    curl -fsSL -o /tmp/fb.tar.gz "${base}/linux-${TARGETARCH}-filebrowser.tar.gz"; \
    curl -fsSL -o /tmp/checksums.txt "${base}/filebrowser_${VERSION}_checksums.txt"; \
    (cd /tmp && grep " linux-${TARGETARCH}-filebrowser.tar.gz\$" checksums.txt | sha256sum -c -); \
    tar -xzf /tmp/fb.tar.gz -C /app filebrowser; \
    tar -xzf /tmp/fb.tar.gz -C /usr/share/licenses/filebrowser LICENSE README.md; \
    chown -R apps:apps /app; chmod -R 755 /app; \
    rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
VOLUME /data
```
Notes:
- `TARGETARCH` is `amd64`/`arm64`, identical to the asset names, so no mapping.
- `/data` exists in the base image, already owned by `apps` (see `apps/ubuntu/Dockerfile`).
- The extra `tar` of `LICENSE` fulfils the licence-notice rule because only the binary is installed to `/app`. `CHANGELOG.md` not shipped.
- No `apt-get`: nothing to add. No pinned apt versions needed.
- `HOME=/config` is already the base default; keep it explicit like `adguardhome-sync`.
- Final `USER apps`; `COPY --chmod=0755 . /` kept.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "filebrowser"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=filebrowser/filebrowser extractVersion=^v(?<version>.+)$
  default = "2.63.23"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/filebrowser/filebrowser"
}
```
Then the standard `group "default"`, `target "image"`, `"image-local"` (`filebrowser:${VERSION}`), `"image-all"` (amd64 + arm64) copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate: `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/filebrowser/filebrowser"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: FB_PORT
    default: "8080"
    required: false
  - name: FB_ADDRESS
    default: "0.0.0.0"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /data
    required: false
```
- Defaults must match `start.sh` and `defaults/settings.json`.
- Port 8080 replaces upstream 80 because rootless `apps` cannot bind below 1024 reliably (see section 9).
- `dependencies:` omitted (none).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config

# Seed once; never overwrite user state
if [ ! -f /config/settings.json ]; then
  cp /defaults/settings.json /config/settings.json
fi

cd /app
# FB_PORT / FB_ADDRESS are read by filebrowser itself (and by upstream's healthcheck)
exec /app/filebrowser --config /config/settings.json "$@"
```
`defaults/settings.json`:
```json
{
  "port": 8080,
  "baseURL": "",
  "address": "0.0.0.0",
  "log": "stdout",
  "database": "/config/filebrowser.db",
  "root": "/data"
}
```
- Idempotent, seeds only when missing, nothing written to `/app`, database in `/config`, listens on `0.0.0.0`.
- If `FB_PORT`/`FB_ADDRESS` are set they should override the JSON (viper env binding); UNVERIFIED precedence for this version, confirm by running with `-e FB_PORT=9090`.
- No secret in files or process list: the admin password is generated by filebrowser itself on first start (verify; draft caveat).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /health
filePaths:
- /app/filebrowser
- /defaults/settings.json
```
- Covers the one declared port with an HTTP probe on the endpoint upstream itself uses for health (`/health`). If it does not return 200 unauthenticated, fall back to `tcp: - port: '8080'` plus `path: /`; do not drop the probe.
- The test runs with no env vars; everything above works on defaults.
- `timeoutSeconds` omitted (180 s minimum is enforced; startup takes seconds).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/database/filebrowser.db` | `/config/filebrowser.db` (config JSON `database`) |
| `/config/settings.json` | stays in `/config`, seeded by `start.sh` |
| `/srv` (served files) | `/data` (root in config), mounted by the user |
| port 80 | 8080 (non-privileged) |
| `UID=1000` user | base user `apps` (568) |
| temp files | none known; set nothing. UNVERIFIED: uploads write temp chunks under the served root, check on run. |

Draft expectations reconciled: non-root yes (568), `readOnlyRootFilesystem: true` yes (writes only to `/config` and `/data`), privileged no, extra persistence `/database` and `/data`: `/database` is folded into `/config`; `/data` kept as a second volume. Note that mounting `/data` read-write gives the app write access to everything in it; mount only the folders it should manage.

## 10. Risks, caveats and open questions

- **Archived upstream (blocker-level for long-term maintenance):** no more releases, bug fixes or security fixes. The README also documents that sessions are non-revocable JWTs. Ask maintainers whether to still port; if yes, note it in the PR description and settings. Renovate will never update this.
- Draft caveat: admin password is generated on first start and printed in logs; confirm exact behaviour and document it.
- Draft caveat: data location conflict resolved as above (`/config` for settings and DB, `/data` for files).
- Binary static-linking UNVERIFIED (see section 1).
- Port change 80 to 8080: the TrueCharts chart must set the container port to 8080.
- No arm64 or musl blocker: `linux-arm64` asset exists, glibc base.

## 11. Build and test steps

```sh
cd apps/filebrowser
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create filebrowser-probe-config
docker run --rm -d --name filebrowser-probe --read-only --tmpfs /tmp \
  -v filebrowser-probe-config:/config filebrowser:2.63.23
docker logs -f filebrowser-probe     # expect the listening line on 0.0.0.0:8080 and the generated admin password line
curl -fsS http://<container-ip>:8080/health   # from another container, not only localhost
docker rm -f filebrowser-probe; docker volume rm filebrowser-probe-config
forgetool containers test --image filebrowser:2.63.23 --config ./apps/filebrowser/container-test.yaml
```
Also run once with a bind-mounted writable `/data` and confirm an upload works under `--read-only`. Max 10 rounds.

## 12. PR checklist

- [ ] Branch `feat/add-filebrowser`; commit and PR title `feat(filebrowser): add new container`; target `main`.
- [ ] PR template filled, only applicable boxes checked.
- [ ] Notes: `🤖 This PR is AI generated.` plus the "upstream archived 2026-09-01" warning.
- [ ] CLA notice to the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- [ ] `docker buildx bake --print` passed; `ARG VERSION` equals bake `VERSION` (`2.63.23`).
- [ ] Untested until run: image build, arm64 build, read-only start with empty `/config`, upload to `/data`, env override of `FB_PORT`, first-run password log line, forgetool run. State this honestly; do not tick "Built container locally" unless done.
