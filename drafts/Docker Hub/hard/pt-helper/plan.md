# pt-helper — implementation plan
> Source: ./draft.md · Target: apps/pt-helper/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | Only the `latest` tag exists on Docker Hub (`crazyq/pt_helper`, about 160 MB, last updated about 3 years ago). No version number found. The page mentions v1 vs v2 data incompatibility. |
| Renovate | `datasource=docker depName=docker.io/crazyq/pt_helper versioning=loose` tracking the digest only. UNVERIFIED that this is useful; the image appears abandoned. |
| License | None stated. The "License" on the page is a feature-unlock key, not a software licence. Treat as proprietary. |
| Source URL | https://hub.docker.com/r/crazyq/pt_helper (no repository, no Dockerfile; contact by WeChat/email only). |
| Download URLs | None. Only the vendor image. Architectures per Docker Hub: AMD64, ARM, ARM64. |
| Checksum source | Image digest only (pin with `@sha256:`). |
| Upstream Dockerfile | Does not exist publicly. UNVERIFIED: runtime (language, glibc/musl, entrypoint, user, file layout). |
| What the app is | PT小助手: automates private-tracker torrent "brushing" and daily check-ins; talks to qBittorrent, Deluge 2 and Transmission; about 20 PT sites. |
| Ports | 8192/tcp (web UI). The draft guessed 8080; Docker Hub says 8192. |
| Volumes | `/data` (application data). |
| Auth | Default web login `admin` / `admin`. |
| Env | None documented. |

## 2. Target layout

Conditional: build only if the blockers in section 10 are cleared.
```
apps/pt-helper/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh      # data-dir redirect and exec of the vendor entrypoint
```
No `root/`, no `defaults/` unless the inspection (section 4 step 1) shows a seed file is needed. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` is the default, but only works if the vendor payload is a glibc-compatible binary or an interpreted app whose runtime is installable. If inspection shows Python, use `ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`; if Node, `python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`. Closest sibling: none in the repo for closed-source vendor-image extraction; `apps/steamcmd` for a vendor payload on ubuntu.

## 4. Dockerfile

1. Inspection (not part of the Dockerfile): `docker pull crazyq/pt_helper:latest`, `docker image inspect` (Entrypoint, Cmd, User, Env, ExposedPorts), `docker create` + `docker export | tar -t` to find the app directory, runtime and libc. Record the findings before writing anything.
2. If it is a musl (alpine) payload, stop: it does not run on glibc ubuntu (blocker).
3. `FROM <chosen base>`, `ARG VERSION` (the pinned image digest label), `ARG TARGETARCH`.
4. `COPY --from=docker.io/crazyq/pt_helper:latest@sha256:<digest> <app path from step 1> /app/` (UNVERIFIED path). The brief allows copy-from only because no binary download exists.
5. `USER root` only for installing the runtime packages the payload needs; no apt unless step 1 requires it.
6. `chown -R apps:apps /app` is not needed if read-only; ensure `chmod -R a+rX /app`.
7. Licence: no licence text exists to ship; add a notice file `/usr/share/licenses/pt-helper/NOTICE` stating the origin and that no licence was published (needs maintainer approval).
8. `ENV HOME=/config`, caches to `/tmp`.
9. `USER apps`
10. `COPY --chmod=0755 . /`
11. `EXPOSE 8192`, `VOLUME /config`, `CMD ["/start.sh"]`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "pt-helper" }
variable "VERSION" {
  // renovate: datasource=docker depName=docker.io/crazyq/pt_helper versioning=loose
  default = "latest"   // UNVERIFIED: use a date-like or digest-based tag chosen when porting
}
variable "LICENSE" { default = "LicenseRef-Proprietary" }   // no licence published
variable "SOURCE"  { default = "https://hub.docker.com/r/crazyq/pt_helper" }
```
The four standard targets plus the default group as in `apps/adguardhome-sync`. `docker buildx bake --print` must pass.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://hub.docker.com/r/crazyq/pt_helper"
ports:
  - port: 8192
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
`TZ` is kept only if inspection shows the app honours it (UNVERIFIED); remove otherwise. Optional integrations (qbittorrent, deluge, transmission exist in `apps/`) are runtime peers configured in the web UI, not hard dependencies.

## 7. start.sh

- `set -euo pipefail`. Create `/config` if missing.
- The app stores data in `/data` (Docker Hub). Redirect: `ln -sfn /config /data` in the Dockerfile (root step) so `/data` is `/config`, avoiding a second volume. UNVERIFIED that the app follows the symlink and does not hard-code other paths.
- Seed nothing unless step 1 shows a default DB/config is required; if so, seed from `/defaults/` only when `/config` is empty.
- Bind to `0.0.0.0:8192` (check that the vendor binary does, from outside the container).
- Final: `exec <vendor entrypoint from inspection> "$@"`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8192'
filePaths:
- /start.sh
- /app
```
The web UI path for an http probe is UNVERIFIED; upgrade the tcp probe to `http` on `/` once the real response is seen (expect the login page). No env vars are needed to start.

## 9. Rootless and read-only-rootfs adaptations

| Upstream | Remap |
|---|---|
| Runs as root (chart runAsUser 0) | Run as `apps`. UNVERIFIED that the closed binary tolerates a non-root user. |
| `/data` (PVC) | `/data` symlink to `/config`. |
| Unknown writes (DB, logs, temp) | Discover with `docker run --read-only --tmpfs /tmp` and `inotifywait`/strace, then redirect to `/config` or `/tmp`. |

Reconciles the draft: confidence was low; chart expected root with writable rootfs, which this plan does not provide.

## 10. Risks, caveats and open questions

- Blocker: closed source, no licence, redistribution not permitted/unknown. Rebuilding the vendor files inside a ContainerForge image republishes them. Get maintainer approval (or the vendor's permission) before opening a PR; otherwise do not port.
- Blocker candidates: musl payload, hard-coded root, unknown runtime, image last updated about 3 years ago (security debt, no Renovate-trackable versions).
- No public Dockerfile, so provenance and build reproducibility cannot be verified.
- Default `admin/admin` login must be called out.
- Port 8192, not 8080 as the draft guessed.
- Needs accounts/cookies for PT sites; many tracker rules restrict automation.
- UNVERIFIED count: 8 (runtime, layout, user, libc, symlink behaviour, TZ, http path, licence).

## 11. Build and test steps

```sh
cd apps/pt-helper
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create pt-helper-probe-config
docker run --rm -d --name pt-helper-probe --read-only --tmpfs /tmp \
  -v pt-helper-probe-config:/config pt-helper:<version>
docker logs -f pt-helper-probe   # expect a "listening on :8192"-style line (UNVERIFIED wording), no crash loop
docker rm -f pt-helper-probe; docker volume rm pt-helper-probe-config
forgetool containers test --image pt-helper:<version> --config ./apps/pt-helper/container-test.yaml
```
Also confirm login with `admin`/`admin` from another container and that data persists after restart on the same volume.

## 12. PR checklist

- Branch `feat/add-pt-helper`; commit and PR title `feat(pt-helper): add new container`; target `main`. Do not open it before the licence question in section 10 is resolved.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what was not tested: everything not actually run, in particular rootless operation, arm64, and any licence/redistribution review.

## Fix attempt (2026-11-28)

Policy blocker set aside as authorised; the runtime unknowns were resolved by reading the Docker Hub registry directly (manifest, config and the small layers of `crazyq/pt_helper:latest`, nothing run). Facts: OCI index digest `sha256:43a4f8707b2c95a767185fabdeb5005aac1109af62fbad74249e24471ba976a8` (amd64, arm64, arm/v7); created 2023-09-07; Alpine 3.10 base; `WorkingDir /bin`, `CMD ["pt_helper"]`, `EXPOSE 8192`, `VOLUME /data`, `TZ=Asia/Shanghai`, no `USER` (root). The binary `/bin/pt_helper` is a stripped Go ELF (CGO, `chromedp`) linked to the musl loader. `/bin/config/config.toml` has `version = "2.4.3"`, `logpath = "/data/logs"` and `link = "sqlite:/data/pt_helper.db"`; templates in `/bin/template`, assets in `/bin/public`, an empty db in `/bin/pt_helper.db`.

Resolution of the musl blocker: Ubuntu's `musl` package (verified on packages.ubuntu.com for resolute, amd64 `/usr/lib/ld-musl-x86_64.so.1`, arm64 `/usr/lib/ld-musl-aarch64.so.1`) provides the loader, so the ubuntu base can run it. Files written: Dockerfile (multi-stage `COPY --from=` the digest-pinned vendor image, `/data` symlinked to `/config`, payload in read-only `/app`), docker-bake.hcl (`VERSION` 2.4.3), settings.yaml, container-test.yaml, start.sh (seeds the vendor empty db, runs from `/app`), `usr/share/licenses/pt-helper/NOTICE`.

Not copied on purpose: chromium (Alpine package, no deb on Ubuntu; chromedp-based features such as browser-driven site handling will not work) and `msyh.ttc` (Microsoft font, redistribution not allowed). Remaining and UNVERIFIED: no licence exists so redistribution needs maintainer or vendor approval; arm64 payload not inspected (only amd64); whether the app runs as UID 568 and writes only to `/data` and `/app`-relative paths; whether it needs the db seeded or creates it itself; what port 8192 serves on `/`; the default login `admin`/`admin` must be changed by the user; nothing was built or run.
