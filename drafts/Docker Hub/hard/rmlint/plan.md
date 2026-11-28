# rmlint — implementation plan
> Source: ./draft.md · Target: apps/rmlint/ · Difficulty: hard in the draft, medium here (the selkies desktop is dropped, so it is a plain CLI image) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Upstream version | v2.11.0 (GitHub release, 2026-11-01, no release assets) |
| Version shipped in the image | 2.10.2, from Ubuntu 26.04 (resolute) `rmlint 2.10.2-0.2ubuntu1`, amd64 and arm64, component universe (packages.ubuntu.com) |
| Draft tag | `bobbintb/docker-rmlint-unraid:latest` is a community build and not an upstream release. Not used. |
| Renovate | Not usable for the apt version (same situation as `apps/valkey`). `VERSION` is pinned to the apt version and bumped by hand when the ubuntu base changes. For information only: upstream is `datasource=github-releases depName=sahib/rmlint`. |
| License | GPL-3.0 (README: "licensed under the conditions of the GPLv3", terms in COPYING). SPDX `GPL-3.0-only`. UNVERIFIED: whether it is `-only` or `-or-later` (not read from the file headers). |
| Source | https://github.com/sahib/rmlint (docs https://rmlint.readthedocs.io/en/master/) |
| Download URLs | None. Install from apt on both architectures. v2.11.0 has no assets. |
| Checksum | Not applicable: apt verifies the package signature. |
| Upstream Dockerfile reviewed | bobbintb/docker-rmlint-unraid Dockerfile (summary only, the fetch tool would not give it verbatim): base `ghcr.io/linuxserver/baseimage-selkies:ubuntunoble`, installs a `.deb` from the bobbintb releases, ENV `TITLE=rmlint`, `CUSTOM_PORT=8321`, `CUSTOM_HTTPS_PORT=8322`, EXPOSE 8321 8322, `VOLUME /config`. |
| Ports | rmlint is a CLI tool and listens on nothing. The draft's 3000/3001 (selkies) and the reference image's 8321/8322 belong to the desktop wrapper and are dropped. |
| Env vars | rmlint reads none that are documented. UNVERIFIED: whether it honours `XDG_CACHE_HOME` (set it to `/tmp` anyway). |
| Build system | SCons (`SConstruct` present). UNVERIFIED, not needed for the apt route. |

## 2. Target layout

- `apps/rmlint/Dockerfile`
- `apps/rmlint/docker-bake.hcl`
- `apps/rmlint/settings.yaml`
- `apps/rmlint/container-test.yaml`
- `apps/rmlint/start.sh`

No `defaults/`, `health/` or `etc/` are needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (nothing uses it as a `FROM`).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Fits because rmlint is a native tool that apt provides on 26.04 for amd64 and arm64. No language runtime is needed. Closest sibling: `apps/valkey` (pinned apt package checked against `VERSION`).

## 4. Dockerfile

1. `ARG VERSION` and `ARG PACKAGE_VERSION`, then `USER root`.
2. One `RUN` as in valkey, so the image really contains the tagged version:
   ```dockerfile
   RUN test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
       apt-get update && \
       apt-get install -y --no-install-recommends "rmlint=${PACKAGE_VERSION}" && \
       apt-get purge -y --auto-remove && \
       rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
   ```
   Packages not already in the base: only `rmlint`. Do not install `rmlint-gui` (GTK). Confirm the exact version string with `apt-cache policy rmlint` on the pinned base before committing. UNVERIFIED: that `2.10.2-0.2ubuntu1` is still the current resolute version at build time.
3. License files: `mkdir -p /usr/share/licenses/rmlint && cp /usr/share/doc/rmlint/copyright /usr/share/licenses/rmlint/` (path to confirm in the built image).
4. `ENV HOME=/config XDG_CACHE_HOME=/tmp XDG_CONFIG_HOME=/config`.
5. `USER apps`, then `COPY --chmod=0755 . /`.
6. `WORKDIR /config`, `VOLUME /config`. No `EXPOSE` (no ports).
7. `CMD ["/start.sh"]`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "rmlint" }
variable "VERSION" {
  // NOTE: tied to the apt package of the ubuntu base image in the Dockerfile; no renovate datasource fits.
  // renovate: datasource=github-releases depName=sahib/rmlint versioning=semver
  default = "2.10.2"
}
variable "PACKAGE_VERSION" { default = "2.10.2-0.2ubuntu1" }
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/sahib/rmlint" }
```
Caveat: the renovate comment above would propose 2.11.0, which the apt package does not have. Keep the comment line for the repo's convention but add `disabled` handling the way valkey does (the commented-out repology line), or drop the datasource and keep only the NOTE. Decide when implementing, and make Dockerfile `ARG`s match. Add `PACKAGE_VERSION` to `image.args`. Targets: `docker-metadata-action`, `image` (labels source and licenses), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`), `group "default"` with `image-local`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json`, `schema_version: 1`, `upstream_env_url: "https://github.com/sahib/rmlint"`.
- `ports:` none (`ports: []`). Reason: CLI tool.
- `env`: `TZ` default `Etc/UTC`, required false; `RMLINT_ARGS` default `""`, required false (arguments read by our `start.sh`, not by rmlint; for example `/data -o json:/config/rmlint.json`).
- `volumes`: `/config` required true (reports and `rmlint.sh` output); `/data` required false (directory to scan, user-mounted).
- `dependencies:` none.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -eu`.
- `cd /config` so `rmlint.sh` and `rmlint.json` land in the persistent volume. `mkdir -p /config` is harmless when it already exists.
- If `RMLINT_ARGS` is non-empty: `exec rmlint ${RMLINT_ARGS}` (word-splitting is intended; document it). Otherwise run `rmlint --version` once, log `rmlint ready: idle, use docker exec or set RMLINT_ARGS`, then `exec sleep infinity` so the container stays up for `docker exec`/Kubernetes jobs and for the container test.
- No writes to `/app`. Nothing to seed in `/config`. Network: not applicable.
- Design choice to confirm with the user: the idle default is ours, upstream defines no daemon mode.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
healthCommands:
- command: rmlint --version
filePaths:
- /usr/bin/rmlint
- /start.sh
```
No port probe is needed because section 6 declares no ports. The test runs without env vars, so the idle path is the one exercised. The `RMLINT_ARGS` path must be run by hand (section 11).

## 9. Rootless and read-only-rootfs adaptations

- Draft expects root (runAsUser 0), `readOnlyRootFilesystem: false` and `/root` as a pvc search location. Reconciled: run as `apps` (568), read-only rootfs, scan target mounted at `/data`, outputs in `/config`, cache in `/tmp`.
- rmlint writes: its report files into the current directory (remapped to `/config` by `WORKDIR`), possibly a cache under `XDG_CACHE_HOME` (remapped to `/tmp`; UNVERIFIED).
- Deleting or replacing duplicates needs write permission on `/data`: the mount must be owned by or writable for UID/GID 568 (`fsGroup: 568` in Kubernetes). No privileged mode is needed.
- The linuxserver selkies desktop base (root, s6, VNC) is not reproduced. If the user wants the GUI, that is a separate, much harder app.

## 10. Risks, caveats and open questions

- Version drift: apt ships 2.10.2 while upstream is at 2.11.0. Accept it or build from source with SCons in a build stage (not verified, adds a toolchain).
- Draft caveat "mount scan dirs with the right permissions" is real; see section 9.
- Draft caveat "reference image is not an upstream release": confirmed, the plan does not use it.
- The idle `sleep infinity` default and `RMLINT_ARGS` are our wrapper design, not upstream features. Confirm that this is wanted instead of a desktop.
- UNVERIFIED: the exact path of the copyright file, whether rmlint touches `$HOME` or the XDG cache.
- No blocker (not musl, no GPU, no privileged, arm64 available via apt).

## 11. Build and test steps

Follow `.github/instructions/build-test-protocol.instructions.md` for `apps/rmlint`, one app at a time, 10 rounds at most.

```sh
cd apps/rmlint
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create rmlint-probe-config
docker run --rm -d --name rmlint-probe --read-only --tmpfs /tmp \
  -v rmlint-probe-config:/config rmlint:2.10.2
docker logs -f rmlint-probe
forgetool containers test --image rmlint:2.10.2 --config ./apps/rmlint/container-test.yaml
docker rm -f rmlint-probe; docker volume rm rmlint-probe-config
```

- Expected readiness signal: log line "rmlint ready: idle" and the container stays running (`docker exec rmlint-probe rmlint --version` works).
- Always start with an empty `/config` volume (fresh volume each round).
- By-hand checks outside the test: run with `-e RMLINT_ARGS="/data -o json:/config/rmlint.json"` and a mounted directory containing duplicate files; check the report lands in /config as UID 568.
- Only try arm64 if an amd64 build is green and a failure is arm64-specific.

## 12. PR checklist

- Branch `feat/add-rmlint` from a freshly pulled `main`; commit and PR title `feat(rmlint): add new container`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md` keeping its sections; check only the boxes that apply. Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows the status). Only the user can sign it.
- Confirm: changes only in `apps/rmlint/`; `ARG VERSION` matches `docker-bake.hcl`; `docker buildx bake --print` passes; final `USER apps`; `COPY --chmod=0755 . /` present; runs read-only with empty `/config`; no assertion weakened.
- Not tested, to state honestly in the PR unless done: arm64 build, the RMLINT_ARGS scan path, the pinned apt version at build time.
