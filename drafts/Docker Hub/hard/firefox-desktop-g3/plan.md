# firefox-desktop-g3 — implementation plan

> Source: ./draft.md · Target: apps/firefox-desktop-g3/ · Difficulty: hard (desktop/VNC stack) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | Firefox 160.0.1 (`LATEST_FIREFOX_VERSION` from product-details.mozilla.org on 2026-11-23; `LAST_RELEASE_DATE` 2026-11-20). ESR is 153.7.0esr. The draft pins nothing (`accetto/...:latest`), so this plan pins the Firefox release |
| Renovate | No GitHub releases. Tags in `mozilla-firefox/firefox` look like `FIREFOX_160_0_1_RELEASE` (verified for 160.0.1). Use `datasource=github-tags depName=mozilla-firefox/firefox versioning=loose extractVersion=^FIREFOX_(?<version>[0-9_]+)_RELEASE$`; the underscores are not converted to dots by this regex, so this needs a repo-level renovate custom rule (UNVERIFIED how this repo handles it). Fallback: `datasource=custom` against `https://product-details.mozilla.org/1.0/firefox_versions.json` (key `LATEST_FIREFOX_VERSION`) |
| License | MPL-2.0 (GitHub API reports NOASSERTION for the repo; MPL-2.0 is Mozilla's published license, UNVERIFIED via API). Bake `LICENSE=MPL-2.0` |
| Source URL | https://github.com/mozilla-firefox/firefox (SOURCE) |
| Per-arch downloads | amd64: `https://archive.mozilla.org/pub/firefox/releases/${VERSION}/linux-x86_64/en-US/firefox-${VERSION}.tar.xz` (HTTP 200, 90,943,956 bytes). arm64: `https://archive.mozilla.org/pub/firefox/releases/${VERSION}/linux-aarch64/en-US/firefox-${VERSION}.tar.xz` (directory exists, HTTP 200) |
| Checksum source | `https://archive.mozilla.org/pub/firefox/releases/${VERSION}/SHA256SUMS`. For 160.0.1: x86_64 `844d8a77aa4672a08ded949b6206f84d91bb82f6637c090fd58c3126e9d44119`, aarch64 `6cf6cac855472e9268ff611d897af1bea951ae9cdcd809e2ad1bcedce6459323`. Fetch SHA256SUMS at build time and `grep` the line for the arch path |
| Upstream Dockerfile reviewed | `accetto/ubuntu-vnc-xfce-g3` `docker/Dockerfile.xfce.24-04`: user `headless` UID 1001, HOME `/home/headless`, VNC 5901, noVNC 6901, env `VNC_PW=headless`, `VNC_RESOLUTION=1360x768`, `VNC_COL_DEPTH=24`, Firefox from Mozilla apt repo (`packages.mozilla.org`, key fingerprint checked), entrypoint `tini -- /dockerstartup/startup.sh`, no shm size set. Repo license MIT (the accetto scripts, not Firefox) |
| Draft ports | 6901 and 5901 are accetto-specific. The kasmvnc sibling in this repo exposes 3000 (HTTP) and 3001 (HTTPS) instead; this plan follows the sibling |
| Existing sibling | `apps/kasmvnc` (KasmVNC 1.5.2 + kclient, openbox, nginx, user `apps`, `HOME=/config`, entrypoint `/start.sh`, `/defaults/autostart` runs the desktop app) |

## 2. Target layout

```
apps/firefox-desktop-g3/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh                 prepares the profile, then execs the kasmvnc entrypoint
  defaults/autostart       openbox autostart that launches Firefox
  defaults/policies.json   Firefox enterprise policy (disable updates, telemetry, default browser check)
```

`defaults/` replaces the kasmvnc seed files (`/defaults/autostart`); `start.sh` is mandatory because the image needs a wrapper around kasmvnc's own start script. No `root/`. No `DOWNSTREAM_CHANGES.md` for this app. Side effect to record in the PR: this app depends on the file contract of `apps/kasmvnc` (`/start.sh`, `/defaults/autostart`), so kasmvnc changes can break it; consider adding a `DOWNSTREAM_CHANGES.md` entry in `apps/kasmvnc` when kasmvnc is next touched (not part of this PR).

## 3. Base image

`FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:<digest>` (tag from `apps/kasmvnc/docker-bake.hcl` `VERSION`; digest UNVERIFIED, get it with `docker buildx imagetools inspect ghcr.io/trueforge-org/kasmvnc:1.5.2` and confirm the image is published). Reason: the repo already ships the VNC + web client + openbox desktop (the draft's "kasmvnc or xvfb sibling"), so only Firefox must be added. Fallback if kasmvnc is not published: build in the `ubuntu` base `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` and port the kasmvnc stages (not recommended).

## 4. Dockerfile

1. `FROM` kasmvnc line above; `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. `mv /start.sh /kasmvnc-start.sh` (the base's entrypoint script; our `COPY . /` later installs our own `/start.sh`).
3. Install Firefox runtime libraries not already in the base (verify with `ldd /app/firefox/firefox | grep "not found"` and add only what is missing; candidates, UNVERIFIED names on 26.04: `libgtk-3-0t64 libdbus-glib-1-2 libasound2t64 libxtst6 libx11-xcb1 libxt6t64 libxcomposite1 libxdamage1 libpci3 fonts-liberation`). Do not re-install what kasmvnc already provides (it already has pulseaudio, fonts-noto, mesa, libgbm, xauth).
4. Download and verify:
   ```
   case "$TARGETARCH" in amd64) FF_ARCH=linux-x86_64;; arm64) FF_ARCH=linux-aarch64;; esac
   curl -fL -o /tmp/ff.tar.xz "https://archive.mozilla.org/pub/firefox/releases/${VERSION}/${FF_ARCH}/en-US/firefox-${VERSION}.tar.xz"
   curl -fL -o /tmp/SHA256SUMS "https://archive.mozilla.org/pub/firefox/releases/${VERSION}/SHA256SUMS"
   (cd /tmp && grep " ${FF_ARCH}/en-US/firefox-${VERSION}.tar.xz\$" SHA256SUMS | sed "s#${FF_ARCH}/en-US/##" | sha256sum -c -)
   mkdir -p /app && tar xJf /tmp/ff.tar.xz -C /app    # creates /app/firefox
   ```
5. Licenses: copy `/app/firefox/LICENSE`-style files if present (UNVERIFIED names; Mozilla tarballs ship `about:license` from omni.ja, so also write a short `/usr/share/licenses/firefox-desktop-g3/NOTICE` pointing to https://www.mozilla.org/MPL/2.0/ and the Firefox source URL).
6. Policy file: `mkdir -p /app/firefox/distribution` (policies come from `defaults/policies.json` via COPY, placed at `/app/firefox/distribution/policies.json`, so ship it in a path allowed by `.dockerignore`, e.g. `defaults/` then `cp` in the Dockerfile).
7. `ln -s /app/firefox/firefox /usr/local/bin/firefox`; `chown -R apps:apps /app/firefox` is unnecessary (read-only); keep root-owned 755.
8. No extra `ENV` needed: `HOME=/config` is already set in the base. Do not set `MOZ_DISABLE_CONTENT_SANDBOX` by default (see risks).
9. `rm -rf /tmp/* /var/lib/apt/lists/*`; `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 3000 3001`; `VOLUME /config`; `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}
variable "APP" { default = "firefox-desktop-g3" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=mozilla-firefox/firefox versioning=loose extractVersion=^FIREFOX_(?<version>[0-9_]+)_RELEASE$
  default = "160.0.1"
}
variable "LICENSE" { default = "MPL-2.0" }
variable "SOURCE"  { default = "https://github.com/mozilla-firefox/firefox" }
```

Standard `group "default"`, `image` (args `VERSION`; labels source/licenses), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64 + arm64). Fix the renovate regex per section 1 before committing. `docker buildx bake --print`.

## 6. settings.yaml

- `upstream_env_url: "https://github.com/mozilla-firefox/firefox"`.
- ports: `3000` tcp (HTTP web desktop), `3001` tcp (HTTPS web desktop), both `required: false` (same as `apps/kasmvnc/settings.yaml`).
- env (inherited from kasmvnc's start script, which really reads them): `TZ` (`Etc/UTC`), `CUSTOM_PORT` (`3000`), `CUSTOM_HTTPS_PORT` (`3001`), `CUSTOM_USER` (`apps`), `PASSWORD` (`""`), `SUBFOLDER` (`/`), plus `FIREFOX_ARGS` (`""`, appended to the Firefox command line in `defaults/autostart`; only list it if the autostart script really reads it). Draft env `VNC_PW`, `VNC_RESOLUTION` are accetto-specific and must not be listed.
- volumes: `/config` required (Firefox profile in `/config/.mozilla`).
- dependencies: `kasmvnc` is the base image, not a runtime dependency; do not list it under `dependencies:`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /config/.mozilla /config/.cache /config/Downloads /tmp/firefox
# first-run only: seed openbox autostart (kasmvnc copies /defaults/autostart when missing)
# shm: warn when /dev/shm is small
shm_kb=$(df -k /dev/shm | awk 'NR==2{print $2}')
(( shm_kb >= 1000000 )) || echo "warning: /dev/shm is small; run with shm_size >= 1g or Firefox tabs may crash"
export XDG_CACHE_HOME=/tmp/firefox
exec /kasmvnc-start.sh "$@"
```

`defaults/autostart`: `firefox --profile /config/.mozilla/default ${FIREFOX_ARGS:-} &` loop (restart on exit with a small sleep) so closing Firefox does not leave an empty desktop. Idempotent: the profile directory is created by Firefox only if missing. Caches go to `/tmp` (`XDG_CACHE_HOME`), profile to `/config`. Services bind to all interfaces via the base `start.sh` (`-interface 0.0.0.0`; nginx listens on 3000/3001). Final command is the exec of the kasmvnc start script, which itself ends in `exec node index.js`. Existing `/config` that already has an older `autostart` keeps it (seeded only when missing), so document that users must delete it to pick up changes.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '3000'
- port: '3001'
filePaths:
- /app/firefox/firefox
- /app/firefox/distribution/policies.json
runners:
- entrypoint: /app/firefox/firefox --version
```

Both settings.yaml ports have a probe. The `runners` entry mirrors `apps/bookstack` (`php --version`); confirm the schema accepts `entrypoint` with arguments. No env var is required, so default start works. An `http` probe on 3000 can be added once the base returns a stable status without `PASSWORD`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/home/headless` profile and Downloads | `/config/.mozilla`, `/config/Downloads` (HOME=/config) |
| `~/.cache/mozilla` | `/tmp/firefox` via `XDG_CACHE_HOME` |
| `/tmp/.X11-unix`, pulse runtime | `/tmp` (kasmvnc base already uses `PULSE_RUNTIME_PATH=/tmp/pulse`) |
| Firefox auto-update into install dir | disabled with policy `DisableAppUpdate: true` (install dir is read-only) |
| `/UNRAID_SHARE` (draft's extra persistence) | not part of the image; users mount any path they want at `/config/Downloads` or elsewhere |

Draft expectations: chart runs UID 0 with `readOnlyRootFilesystem: false`; here UID 568, read-only rootfs, no privileged mode. kasmvnc's base adds `apps` to sudoers (`NOPASSWD`), which is upstream baggage and not exercised under `--read-only`.

## 10. Risks, caveats and open questions

- Base `ghcr.io/trueforge-org/kasmvnc` tag and digest are UNVERIFIED; the plan only works if that image is published on ghcr.
- kasmvnc's own start.sh contract (`/start.sh`, `/defaults/autostart`, ports 3000/3001) is relied on; its recent history shows active edits.
- Firefox content sandbox needs unprivileged user namespaces; with restrictive seccomp/AppArmor the content process may fail. Mitigation is `MOZ_DISABLE_CONTENT_SANDBOX=1` (UNVERIFIED effect/availability on 160.x) which lowers security; make it an opt-in env only if testing shows it is needed.
- `/dev/shm` default 64 MB is too small; recommend `shm_size: 1g` in docs. The draft marks this as inferred; confirmed as general Firefox guidance, not tested here.
- Draft arm64 note: Mozilla publishes `linux-aarch64` builds, so arm64 is possible, but the kasmvnc base must itself build for arm64 (it uses amd64-only Intel drivers conditionally, so it should).
- Renovate extraction of `FIREFOX_160_0_1_RELEASE` needs a custom rule; ESR vs release channel is a product decision (this plan follows the release channel).
- Ports differ from the draft (3000/3001 instead of 6901/5901); the draft's `VNC_PW` style auth is replaced by kasmvnc `PASSWORD`/`CUSTOM_USER` basic auth.
- Draft says dependency containers: none, which holds.

## 11. Build and test steps

```sh
cd apps/firefox-desktop-g3
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name firefox-desktop-g3-probe --read-only --tmpfs /tmp --shm-size=1g \
  -v firefox-desktop-g3-probe-config:/config firefox-desktop-g3:160.0.1
docker logs -f firefox-desktop-g3-probe
forgetool containers test --image firefox-desktop-g3:160.0.1 --config ./apps/firefox-desktop-g3/container-test.yaml
docker rm -f firefox-desktop-g3-probe; docker volume rm firefox-desktop-g3-probe-config
```

Readiness signals: kasmvnc/Xvnc lines in the log, nginx started, kclient listening, ports 3000/3001 open, `pgrep -x firefox` (or `firefox-bin`) present after 10 s. Manually open http://localhost:3000 and load a page to confirm the sandbox works. Run with `--shm-size` default once to confirm the warning path. Cap at 10 rounds.

## 12. PR checklist

- Branch `feat/add-firefox-desktop-g3`; commit `feat(firefox-desktop-g3): add new container`; same PR title; target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`; check only boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign; `license/cla` check shows status).
- List untested items: kasmvnc base availability, arm64, content sandbox, shm behavior, renovate rule for Firefox tags.
- Pre-completion: bake `--print` ok, Dockerfile/bake version aligned, rootless + read-only verified, empty `/config` start verified.
