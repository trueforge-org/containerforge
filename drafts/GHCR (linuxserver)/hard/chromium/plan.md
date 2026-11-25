# chromium — implementation plan
> Source: ./draft.md · Target: apps/chromium/ · Difficulty: hard · Role: main · Verified on 2026-11-25

Status: BLOCKED as drafted. The upstream image is a Selkies desktop on a Debian base, and the Chromium package it installs is a Debian package. Neither the Selkies stack nor the Debian package source is available on the ContainerForge Ubuntu base. A decision is needed before any `apps/chromium/` work (see section 10).

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No Chromium version is pinned upstream. Chromium is installed by apt, so the version follows the Debian archive. Chromium version: UNVERIFIED (no source fetched shows the trixie package version). |
| Upstream image tag used by chart | `ghcr.io/linuxserver/chromium:latest` (rolling), from draft.md. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-chromium/4ec00555069627093b9110daff841d363f9a95f8/Dockerfile |
| Upstream FROM | `ghcr.io/linuxserver/baseimage-selkies:debiantrixie` (Debian trixie, Selkies desktop stack). |
| Upstream install | `apt-get install -y --no-install-recommends chromium chromium-l10n` from the base's default Debian repos. No extra apt source is added. Same Dockerfile. |
| Upstream ENV | `TITLE=Chromium`, `PIXELFLUX_WAYLAND=true`. |
| Upstream EXPOSE / VOLUME | `EXPOSE 3001`, `VOLUME /config`. No ENTRYPOINT, CMD or USER. |
| Upstream COPY | `COPY /root /` (the s6 service tree of the Selkies base). Not reusable here (see section 9). |
| Upstream cleanup | Removes `/config/.cache`, apt lists, `/var/tmp/*`, `/tmp/*`. |
| Renovate | UNVERIFIED. No version pin to annotate. Likely `datasource=docker` for the base image, not for Chromium. |
| License (wrapper repo) | GPL-3.0 (https://api.github.com/repos/linuxserver/docker-chromium, read with `gh api`). |
| License (Chromium source) | BSD 3-Clause (https://chromium.googlesource.com/chromium/src/+/main/LICENSE). |
| Source URL | https://chromium.googlesource.com/chromium/src |
| Source tarball / per-arch download | None used. Chromium is taken from the Debian archive by apt. Per-arch: UNVERIFIED (Debian trixie arm64 availability not confirmed on a fetched page). |
| Official download page | https://www.chromium.org/getting-involved/download-chromium/ says builds are "made available on a best-effort basis" and points to Chrome for Testing and the continuous Linux build archive. It does not cover Debian or Ubuntu packaging. |
| Checksum source | UNVERIFIED for standalone builds. apt packages are signed by the Debian archive keys. |
| Ports | `3001` (EXPOSE 3001, Selkies web UI). Draft's `3000` is UNVERIFIED and is not exposed upstream. |
| Data / config paths | `/config` (VOLUME), `/config/.cache` (removed by upstream cleanup; chart keeps it as an emptyDir). |
| Ubuntu archive | Draft and Ubuntu's chromium packaging claim: Ubuntu ships chromium as a snap. UNVERIFIED for Ubuntu 26.04: the fetched download page does not say, and no Ubuntu packages page was fetched. |

## 2. Target layout

If, and only if, the blocker in section 10 is resolved, the layout would be:

- `apps/chromium/Dockerfile`
- `apps/chromium/docker-bake.hcl`
- `apps/chromium/settings.yaml`
- `apps/chromium/container-test.yaml`
- `apps/chromium/start.sh`
- `apps/chromium/defaults/` only if a browser profile seed is needed (reason: none identified yet).

Never touch `root/`. No `DOWNSTREAM_CHANGES.md`: this image is not a `FROM` base for other apps.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.

Reason: the Ubuntu base is the ContainerForge foundation for generic userland apps. Closest sibling for a GUI-less browser: none verified. Desktop-style siblings (`apps/kasm`, `apps/kasmvnc`, `apps/xvfb`) were not reviewed in this batch, so the closest sibling is UNVERIFIED and should be checked before work starts.

## 4. Dockerfile

Only applicable if section 10's blocker is resolved. Steps:

1. `ARG VERSION` is not needed for a rolling apt install. If the decision is to pin, add `ARG CHROMIUM_VERSION` and pin the apt package (see the valkey pinning rule) and align it with `docker-bake.hcl`.
2. `USER root`, then `apt-get update && apt-get install -y --no-install-recommends chromium` with the package source the decision chooses. Do not use `chromium-l10n` unless required.
3. Remove apt lists and `/var/cache/apt`.
4. Create `/config` ownership for `apps`. Keep caches and the `HOME` profile in `/tmp` or `/config` only if persistence is required.
5. `COPY --chmod=0755 . /`, `EXPOSE <port>`, `VOLUME /config`, final `USER apps`.

No downloads, no checksums, no license copy from upstream unless the Chromium license text is shipped (BSD-3-Clause, section 1).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "chromium" }
variable "VERSION" {
  // renovate: datasource=<UNVERIFIED> depName=<UNVERIFIED> versioning=loose
  default = "<UNVERIFIED>"
}
variable "LICENSE" { default = "BSD-3-Clause" }
variable "SOURCE" { default = "https://chromium.googlesource.com/chromium/src" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync`. Validate with `docker buildx bake --print`. The VERSION value cannot be set until the Chromium version source is decided (section 10).

## 6. settings.yaml

Schema header per the settings rules, `schema_version: 1`, `upstream_env_url: "https://chromium.googlesource.com/chromium/src"`.

- `ports`: `3001/tcp`, `required: false` (confirmed by upstream EXPOSE). Do not list 3000 (UNVERIFIED).
- `env`: none confirmed to be read by a ContainerForge start script. Do not invent variables. Upstream `TITLE` and `PIXELFLUX_WAYLAND` belong to the Selkies base, not confirmed as app inputs.
- `volumes`: `/config`, `required: true`.
- `dependencies`: none (draft says none, fetched upstream shows none).

## 7. start.sh

Only if the decision keeps a browser process. Must be idempotent, create `/config` profile dirs only when missing, put caches in `/tmp`, and `exec` the browser (or its wrapper). It must bind the web UI to `0.0.0.0` if a web UI is kept. Chromium's headless modes and remote debugging bind addresses are UNVERIFIED for this build.

## 8. container-test.yaml

Schema header per forgetool. `timeoutSeconds` from a desktop-style sibling (UNVERIFIED which sibling). Probes: one `tcp` and one `http` probe for the port in settings.yaml. `filePaths`: the browser binary path (UNVERIFIED: depends on Debian/Ubuntu package layout) and `/usr/share/licenses/chromium/` if a licence file is shipped.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config/.cache` (browser cache, chart emptyDir) | `/tmp` via a cache dir flag or `XDG_CACHE_HOME=/tmp`. UNVERIFIED flag names for this Chromium build. |
| `/config` profile | Keep `/config` as the only persistent path, seeded empty. |
| Browser sandbox (zygote, user namespaces) | Chromium's sandbox needs unprivileged user namespaces or a flag such as `--no-sandbox`. `--no-sandbox` removes a security boundary and needs a written reason. UNVERIFIED whether the Ubuntu base kernel allows unprivileged userns on this platform. |
| `/dev/shm` | Chromium uses shared memory. The chart's common default covers `/dev/shm`. Under `--read-only --tmpfs /tmp`, `/dev/shm` may still need a size. UNVERIFIED. |

Draft security expectations reconciled: chart runs as UID 0 and `readOnlyRootFilesystem: false`. This image must run as `apps` (UID 568) and must work with `--read-only --tmpfs /tmp`. The draft's "non-root no, read-only no" expectations are the chart's values, not a requirement for ContainerForge. The chart's `/config/.cache` is covered by the `/tmp` remap above.

## 10. Risks, caveats and open questions

- Blocker 1: the upstream stack is the Selkies desktop base (`baseimage-selkies`), which the ContainerForge Ubuntu base does not provide.
- Blocker 2: Chromium on Ubuntu 26.04 is UNVERIFIED as an apt package. The draft says it is a snap. Confirm before choosing a source.
- Blocker 3: the sandbox need for unprivileged user namespaces or `--no-sandbox` is UNVERIFIED for this platform. Decide before writing `start.sh`.
- Blocker 4: no arm64 evidence beyond the upstream page's `arm64: yes` in the draft. Debian trixie arm64 availability is UNVERIFIED.
- Caveat: the image tag is rolling (`latest` in the chart). Browser versions change without notice, so a pinned version and a renovate source are needed before shipping.
- Caveat: memory and CPU heavy. Set resource expectations in settings.yaml only if a documented need exists (UNVERIFIED).
- Recommended decision: do not port the Selkies desktop. Either (a) a separate headless-browser design built on the Ubuntu base with a verified Chromium source, or (b) leave the draft in `drafts/` until a source and sandbox policy are chosen.

## 11. Build and test steps

Only after section 10 is decided:

```sh
cd apps/chromium
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name chromium-probe --read-only --tmpfs /tmp \
  -v chromium-probe-config:/config chromium:<VERSION>
docker logs -f chromium-probe
forgetool containers test --image chromium:<VERSION> --config ./apps/chromium/container-test.yaml
docker rm -f chromium-probe; docker volume rm chromium-probe-config
```

Readiness signal: UNVERIFIED (depends on the chosen design's log lines).

## 12. PR checklist

- Branch `feat/add-chromium`, commit and PR title `feat(chromium): add new container`, target `main`.
- Notes section includes `🤖 This PR is AI generated.`
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- State honestly that this plan has not been built or run, and that the sandbox, arm64 and Chromium version are unverified.
