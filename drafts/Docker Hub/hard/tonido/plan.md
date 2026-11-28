# tonido — implementation plan
> Source: ./draft.md · Target: apps/tonido/ · Difficulty: hard (currently BLOCKED, see sections 1 and 10) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | UNVERIFIED: the vendor publishes no version number on a reachable page; draft uses `latest` of `captinsano/tonido` |
| Renovate | None possible: no versioned release feed. Use a manual `VERSION` (for example the date of the tarball) with no renovate datasource, or add `// renovate: datasource=custom...` only if a feed is found. UNVERIFIED |
| License | Proprietary, closed source (terms not verified). Use SPDX `LicenseRef-Proprietary` in `LICENSE` |
| Source URL | https://www.tonido.com/ (no source repository) |
| amd64 download | The upstream Dockerfile uses `http://www.tonido.com/download.php?tonido64.tar.gz`. On 2026-11-24 that URL redirects to https and then returns **HTTP 404** (checked with curl). BLOCKER |
| arm64 download | None (vendor ships `tonido64` only; draft says amd64 only) |
| Checksum source | None published |
| Upstream Dockerfile reviewed | `captinsano/docker-containers` at bc771a3, `Tonido/Dockerfile`: base `phusion/baseimage:0.9.16`; installs wget, tmux, libjpeg8, libfontconfig1, curl; extracts to `/usr/local/tonido`; `LD_LIBRARY_PATH=/usr/local/tonido`; remaps `nobody` to UID 99 / GID 100; `VOLUME /unRAID /config`; `EXPOSE 10001`; runit service runs `/usr/local/tonido/tonidoconsole /config`; `firstrun.sh` does `chown -R nobody:users /config; chmod -R 777 /config` |
| Port | 10001 (upstream Dockerfile EXPOSE; FileCloud headless docs say browse to `http://<server>:10001`). The draft's `10000` is wrong |
| Product status | tonido.com states Tonido keeps working on the LAN but recommends moving to FileCloud community edition (the product is end-of-life) |

## 2. Target layout

Only if the blocker is solved (a legally redistributable tarball URL exists):
```
apps/tonido/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`, `etc/` or `root/`. No `DOWNSTREAM_CHANGES.md` (nothing builds from it). Recommendation: do not port; implement only after a decision on the blocker.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Reason: closed-source x86-64 glibc binary, no language runtime. Closest sibling: `apps/adguardhome-sync` (download + extract to `/app`). Ubuntu 26.04 may be too new for a 2015-era binary (libjpeg8, OpenSSL 1.0 style dependencies): UNVERIFIED, use `ldd` on the binary in the build.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Guard: `RUN test "${TARGETARCH}" = "amd64"` so an arm64 build fails clearly (bake `image-all` must then be restricted to `linux/amd64`).
3. apt: `libjpeg8` (name in 26.04 UNVERIFIED; `libjpeg-turbo8` is the likely provider); `fontconfig` is already in the base; `tmux` is not needed (upstream installed it for no documented reason).
4. Download, no upstream checksum so pin ours: `curl -fsSL -o /tmp/tonido.tar.gz "${TONIDO_URL}"` then `echo "${TONIDO_SHA256}  /tmp/tonido.tar.gz" | sha256sum -c -` (both as `ARG`s with bake variables; values UNVERIFIED because the URL is dead). `mkdir -p /app && tar -xzf /tmp/tonido.tar.gz -C /app`, license/terms files to `/usr/share/licenses/tonido/`.
5. `ENV LD_LIBRARY_PATH=/app/tonido HOME=/config` (upstream path was `/usr/local/tonido`; the archive's top directory name is UNVERIFIED).
6. `chown -R root:root /app && chmod -R a+rX /app`.
7. `USER apps` as the last user directive, then `COPY --chmod=0755 . /`.
8. `EXPOSE 10001`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "tonido" }
variable "VERSION" {
  // renovate: none (closed source, no release feed); bump manually when the tarball URL/checksum changes
  default = "<UNVERIFIED>"
}
variable "LICENSE" { default = "LicenseRef-Proprietary" }
variable "SOURCE"  { default = "https://www.tonido.com/" }
```
No valid `// renovate: datasource=...` line exists for this app; the comment line above documents that. Plus `TONIDO_URL` and `TONIDO_SHA256` variables passed through `args`. Standard targets `docker-metadata-action`, `image`, `image-local`, `image-all` (platforms only `linux/amd64`) and `group "default"`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.tonido.com/"
ports:
  - port: 10001
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /data
    required: false
```
Only `TZ` (handled by the base image). The app reads no documented env vars (upstream image has none): UNVERIFIED. The draft's `/unRAID` share path becomes a user-chosen mount under `/data`. Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -e
mkdir -p /config
export HOME=/config LD_LIBRARY_PATH=/app/tonido
exec /app/tonido/tonidoconsole /config
```
- `tonidoconsole <dir>` is the only invocation seen upstream (runit script); the only argument is the data directory, so state goes to `/config`. Bind address/`0.0.0.0` behaviour UNVERIFIED (check with `ss -ltn` from outside the container).
- Idempotent, nothing written to `/app`, caches stay in `/config` only because Tonido keeps its own profile there (cannot be split: UNVERIFIED).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '10001'
filePaths:
- /app/tonido/tonidoconsole
- /usr/share/licenses/tonido
```
Port 10001 probe covers the only port in settings.yaml. No DB dependency, no narrowing.

## 9. Rootless and read-only-rootfs adaptations

- Draft expects UID 0 / GID 0 and a writable rootfs; upstream remaps `nobody` to 99:100 and runs `chmod -R 777 /config`. We run as `apps` (568) and drop the chmod/chown `firstrun.sh`.
- Upstream writes: `/config` (profile, logs) only, as far as visible; `/usr/local/tonido` may be written by the app at runtime (self-update, logs): UNVERIFIED. If the app writes next to its binary, it cannot be made read-only without symlinks into `/config` or `/tmp`.
- No runit/phusion init; single foreground process via `exec`.
- `/unRAID` share path is replaced by a generic data mount.

## 10. Risks, caveats and open questions

- BLOCKER: the only known download URL returns 404; there is no verified mirror. Without a legal, stable URL the image cannot be built reproducibly. Re-hosting the vendor binary in a public GHCR image may violate the vendor license (terms UNVERIFIED).
- End-of-life vendor product (tonido.com recommends FileCloud); security fixes are not expected.
- Closed-source binary, amd64 only, built for an old glibc/library set; may not run on Ubuntu 26.04.
- Alternative path: `COPY --from=captinsano/tonido:latest` (draft's copy-from) is unpinned (`latest`, no digest) and from a phusion image; if used, pin by digest and record it.
- Possible self-update/write-to-install-dir behaviour is unknown.
- UNVERIFIED count for this plan: 9 (version, renovate, license terms, checksum, archive layout, libjpeg package, bind address, env vars, install-dir writes).

## 11. Build and test steps

Do not start until the download blocker is resolved.
```sh
cd apps/tonido
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create tonido-probe-config
docker run --rm -d --name tonido-probe --read-only --tmpfs /tmp \
  -v tonido-probe-config:/config tonido:<VERSION>
docker logs -f tonido-probe
```
Readiness signal: a log line from tonidoconsole about the HTTP port (upstream NETGEAR log shows `[HttpPort ] = 10001`) and `curl -s http://localhost:10001/` from outside the container returns HTML. Then:
```sh
forgetool containers test --image tonido:<VERSION> --config ./apps/tonido/container-test.yaml
docker rm -f tonido-probe; docker volume rm tonido-probe-config
```

## 12. PR checklist

- Branch `feat/add-tonido`; commit and PR title `feat(tonido): add new container`; target `main`. Do not open the PR until the blocker is resolved (otherwise report as `unfixable`).
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes contain `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign).
- Pre-completion: bake print ok, `VERSION`/`ARG` aligned, final `USER apps`, `COPY --chmod=0755 . /`, license note in `/usr/share/licenses/tonido/`.
- Untested/unknown to state: download URL, checksum, binary compatibility with Ubuntu 26.04, arm64 (not supported), bind address, writes to the install dir.

## Fix attempt (2026-11-28)
- Blocker resolved: the vendor URL still returns 404, but the Internet Archive holds the 2021-10-06 snapshot of `download.php?tonido64.tar.gz` (43,477,755 bytes, sha256 `d5b582f53d455e083604b306c7cb98e836579b5fa9f3c74efc0ccd72157f3a84`). `manifest.xml` inside reports version `14.90.0.34042`, `<License>Free</License>`. The archive is flat (no top directory) and bundles Poco, OpenSSL 1.0, libgd, taglib and wx libs. `VERSION` is now `14.90.0.34042` and the Dockerfile checks it against `manifest.xml`.
- Found by readelf: bundled `libgd.so.2` needs `libpng12.so.0` and `libjpeg.so.8`. `libjpeg-turbo8` exists for Ubuntu resolute; `libpng12` does not, so it is taken from the Ubuntu xenial `.deb` (sha256 pinned in the bake file).
- Files written: Dockerfile, docker-bake.hcl, settings.yaml, container-test.yaml, start.sh.
- Still unresolved: redistribution rights (no licence text in the archive); run-time compatibility on Ubuntu 26.04 (glibc, OpenSSL 1.0 bundled); bind address; whether the app writes to `/app/tonido`; arm64 unsupported. Nothing was built or run.
