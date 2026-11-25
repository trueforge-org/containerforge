# kiwix-serve — implementation plan
> Source: ./draft.md · Target: apps/kiwix-serve/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Upstream tag `3.8.2` (published 2026-03-02). The draft's `3.8.2` is confirmed as a tag. Source: https://api.github.com/repos/kiwix/kiwix-tools/releases/latest |
| Version available via apt | Ubuntu resolute (26.04) universe ships `kiwix-tools 3.7.0-1.1build2`, not 3.8.2. **The apt route cannot give 3.8.2.** Source: https://packages.ubuntu.com/resolute/kiwix-tools |
| Renovate (plan) | `datasource=deb depName=kiwix-tools registryUrl=https://archive.ubuntu.com/ubuntu` (as in section 5; matches `apps/steamcmd`). Only the apt build is shipped, so the image VERSION tracks the apt package until a source build is decided (section 4). If a source build is chosen later, switch to `datasource=github-releases depName=kiwix/kiwix-tools versioning=semver` (tags `r0.1` and `imported_from_kiwix` exist, so the semver filter matters). |
| License | GPL-3.0 (GitHub repo license field, `spdx_id` GPL-3.0). Source: https://api.github.com/repos/kiwix/kiwix-tools. The draft's Dockerfile label points to `openzim/kiwix-tools`; the repo's canonical name is `kiwix/kiwix-tools`. |
| Source URL | https://github.com/kiwix/kiwix-tools |
| Download | No release assets (empty asset list on 3.8.2). The binary comes from apt: `kiwix-tools` (amd64 and arm64 .deb, arm64 confirmed at https://packages.ubuntu.com/resolute/arm64/kiwix-tools/download). |
| Checksum source | apt repository signatures (Ubuntu archive). No upstream checksum file exists because there are no assets. |
| Upstream Dockerfile reviewed | https://github.com/kiwix/kiwix-tools/blob/3.8.2/docker/server/Dockerfile: `FROM ghcr.io/kiwix/kiwix-tools:$VERSION`, `EXPOSE 8080`, `VOLUME /data`, `WORKDIR /data`, user 1001 via busybox `adduser`, `ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/bin/start.sh"]`. The upstream image is therefore a musl (Alpine-style) build; UNVERIFIED for the exact base. |
| Upstream start.sh reviewed | https://github.com/kiwix/kiwix-tools/blob/3.8.2/docker/server/start.sh: `DOWNLOAD` (optional URL, fetched with wget into /data), `PORT` (default 8080), runs `/usr/local/bin/kiwix-serve --port=$PORT $@`. |
| Real env vars (upstream) | `DOWNLOAD` (optional, ZIM URL), `PORT` (default 8080). No other env vars read. |
| Ports | 8080/tcp (`EXPOSE 8080` upstream). |
| Write paths (upstream) | `/data` (VOLUME, WORKDIR). ContainerForge remaps this to `/config`. |
| copy-from | **no**. The upstream image is `ghcr.io/kiwix/kiwix-tools:3.8.2` (musl build, not glibc Ubuntu). Draft's `ghcr.io/kiwix/kiwix-serve:3.8.2` is not the image the upstream Dockerfile builds. |
| arm64 | Yes via apt (`kiwix-tools_3.7.0-1.1build2_arm64.deb`). amd64 presumed same version; UNVERIFIED (amd64 download page not fetched). |
| Dependencies | None. |

## 2. Target layout

Files in `apps/kiwix-serve/`:

- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required; upstream start.sh is not copied, the logic is rewritten for `/config`)
- `include/.dockerignore` already allows `start.sh`, so no extra paths are needed.

Not needed: `defaults/`, `etc/`, `app/`, `health/` (no seeding, no config file, no extra runtime assets). Not `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a FROM base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (copied from `apps/ubuntu` base list in the brief).
- Why: a glibc Ubuntu base, and the binary comes from the Ubuntu archive. No runtime language needed.
- Closest sibling: `apps/adguardhome-sync` (prebuilt binary on ubuntu) and `apps/steamcmd` (apt install pinned on the ubuntu base).
- Universe: `kiwix-tools` is in the `universe` component. The trueforge ubuntu base may not enable universe by default (UNVERIFIED). Enable it the way `apps/steamcmd/Dockerfile` enables multiverse (`add-apt-repository -y universe`) only if `apt-get install kiwix-tools` fails without it.

## 4. Dockerfile

Step list:

1. `ARG VERSION` and `ARG TARGETARCH` (not needed for apt; the package is multi-arch).
2. `USER root` for the install only.
3. `apt-get update`, then `apt-get install -y --no-install-recommends kiwix-tools=${VERSION}` with `VERSION` pinned to the apt version (`3.7.0-1.1build2`), not the upstream tag.
4. `mkdir -p /config`; `chown -R apps:apps /config` (follow the `apps/steamcmd` pattern).
5. `rm -rf /var/lib/apt/lists/*`.
6. `COPY --chmod=0755 start.sh /start.sh` (the path the test list in section 8 expects, as in `apps/steamcmd`).
7. `EXPOSE 8080` (informational; settings.yaml carries the port).
8. `VOLUME /config`.
9. `USER apps`.
10. `COPY --chmod=0755 . /` as the last line (required by the Dockerfile rule).

Key snippet (version alignment, pinned apt package):

```dockerfile
ARG VERSION
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends kiwix-tools=${VERSION} && \
    mkdir -p /config && chown -R apps:apps /config && \
    rm -rf /var/lib/apt/lists/*
COPY --chmod=0755 start.sh /start.sh
VOLUME /config
USER apps
COPY --chmod=0755 . /
```

Caveat for the reviewer: `VERSION` here is the apt version (`3.7.0-1.1build2`; UNVERIFIED that the plain-apt version string matches exactly what the archive carries at build time), so the image is tagged `kiwix-serve:3.7.0-1.1build2` (`${APP}:${VERSION}`). The draft's `3.8.2` cannot be reached through apt. Decision needed (section 10).

## 5. docker-bake.hcl

- `variable "APP" { default = "kiwix-serve" }`
- `variable "VERSION"` with the renovate comment for the apt package (matches the steamcmd sibling pattern):

```hcl
variable "VERSION" {
  // renovate: datasource=deb depName=kiwix-tools registryUrl=https://archive.ubuntu.com/ubuntu
  default = "3.7.0-1.1build2"
}
```

- `variable "LICENSE" { default = "GPL-3.0-only" }` (GitHub reports GPL-3.0; use the SPDX string upstream reports, `GPL-3.0`, after confirming with the LICENSE file in the repo, UNVERIFIED for the exact SPDX variant).
- `variable "SOURCE" { default = "https://github.com/kiwix/kiwix-tools" }`
- The 4 standard targets (`docker-metadata-action`, `image`, `image-local`, `image-all`) and `group "default" { targets = ["image-local"] }`, mirroring `apps/steamcmd/docker-bake.hcl`.
- Validate with `docker buildx bake --print` from `apps/kiwix-serve/`.

## 6. settings.yaml

- Schema header: `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json` and `schema_version: 1`.
- `upstream_env_url: "https://github.com/kiwix/kiwix-tools"` (same as SOURCE).
- `ports`:
  - `port: 8080`, `protocol: tcp`, `required: true`
- `env`:
  - `PORT` default `"8080"`, `required: false` (read by start.sh)
  - `TZ` default `"Etc/UTC"`, `required: false` (matches siblings)
  - `DOWNLOAD` default `""`, `required: false` (optional ZIM URL; start.sh fetches it into /config only when missing)
- `volumes`: `/config`, `required: true`.
- `dependencies`: none.

## 7. start.sh

Requirements from the startup-script rule:

- Idempotent: run cleanly with an empty `/config` and on restarts.
- No writes to `/app` (the app lives in `/usr/bin`, nothing to write there).
- ZIM files live in `/config`, which is the only persistent path.
- Seed nothing by default; do not overwrite user files.
- `exec` kiwix-serve so signals reach PID 1 (no `dumb-init` in our image; the base handles PID 1 as it does for siblings).
- Listen on `0.0.0.0` (kiwix-serve `--address` default is `0.0.0.0`; UNVERIFIED for the 3.7.0 build, check with `ss -ltn` in the run step).

Outline:

```sh
#!/usr/bin/env bash
set -euo pipefail
cd /config
PORT="${PORT:-8080}"
if [ -n "${DOWNLOAD:-}" ]; then
  zim="$(basename "${DOWNLOAD}")"
  if [ ! -s "/config/${zim}" ]; then
    curl -fsSL -o "/config/${zim}.part" "${DOWNLOAD}" && mv "/config/${zim}.part" "/config/${zim}"
  fi
fi
shopt -s nullglob
zims=(/config/*.zim)
if [ "${#zims[@]}" -eq 0 ]; then
  echo "No ZIM files in /config; place a .zim file there and restart." >&2
  exit 1   # see open question on empty-/config behaviour (section 10)
fi
exec kiwix-serve --port="${PORT}" --address=0.0.0.0 "${zims[@]}"
```

Notes:

- Use `/tmp` for the `.part` download if you need scratch; the snippet keeps the download in `/config` because the file must persist.
- `curl` must be available: check the base image; add it to apt install only if absent (UNVERIFIED).
- Empty `/config`: the rule requires the image to start with an empty `/config`. The snippet above exits when there is no ZIM. That fails the protocol's "keep running" criterion. Decide before implementing (section 10).

## 8. container-test.yaml

- Schema header from `apps/steamcmd/container-test.yaml`.
- `filePaths`: `/start.sh`, `/usr/bin/kiwix-serve`.
- A `tcp` probe on 8080 (required: every port in settings.yaml needs one).
- An `http` probe on `/` on 8080 if the app serves a page with no ZIM (UNVERIFIED: whether kiwix-serve answers `/` with no library).
- `timeoutSeconds` copied from a sibling in the same family (`apps/adguardhome-sync` or `apps/steamcmd`).
- Empty `/config` and no env vars: the test runs with none, so the ZIM-present path is not exercised. Add a narrowed note only if the test needs a ZIM, and do not weaken the probes.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | ContainerForge remap |
| --- | --- |
| `/data` (VOLUME, WORKDIR, chown to user 1001) | `/config` (VOLUME), owned by `apps` |
| `/data` WORKDIR | `WORKDIR` not needed; start.sh does `cd /config` |
| User 1001 `user` | `USER apps` (the base's runtime user) |
| wget into `/data` | curl into `/config` only when the file is missing |

- `readOnlyRootFilesystem`: the chart sets false; the image needs nothing outside `/config` and `/tmp`, so it is compatible. Run probe: `--read-only --tmpfs /tmp`.
- `privileged`: no. Port 8080 is unprivileged.
- Extra persistence: none beyond `/config`.
- Caches: none (no pip, no npm).

## 10. Risks, caveats and open questions

- **Version gap (blocker for a 3.8.2 tag):** apt provides 3.7.0. Options: (a) ship apt 3.7.0 and tag as 3.7.0 (recommended for an easy app); (b) build 3.8.2 from source (not easy; needs a build stage). Decide before implementing.
- **Empty `/config` behaviour:** `kiwix-serve` with no ZIM may exit with an error. The protocol requires the container to stay up with an empty `/config`. Confirm behaviour with the 3.7.0 binary in the run step. If it exits, options are a `kiwix-manage` library file created on first start, or a documented exit with a clear message. Do not mark it passing if it exits.
- **Chart draft claim:** the draft says the arm64 apt build "must be verified". arm64 `.deb` confirmed; amd64 not fetched.
- **Image name:** the draft's `ghcr.io/kiwix/kiwix-serve` is not confirmed; upstream builds `ghcr.io/kiwix/kiwix-tools`.
- **Large ZIM files:** users need disk in `/config`; no action in the image.
- **Security expectations (draft):** non-root possible (apps user), read-only rootfs possible (`/config` and `/tmp` only), privileged no. Confirm with the run step.
- **Licensing:** GPL-3.0 from GitHub; confirm the LICENSE file for the bake SPDX string (UNVERIFIED).

## 11. Build and test steps

From `apps/kiwix-serve/`, following `.github/instructions/build-test-protocol.instructions.md`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Run and log check with an empty volume:
   ```sh
   docker volume rm kiwix-serve-probe-config 2>/dev/null || true
   docker run --rm -d --name kiwix-serve-probe --read-only --tmpfs /tmp \
     -v kiwix-serve-probe-config:/config kiwix-serve:3.7.0-1.1build2
   docker logs -f kiwix-serve-probe
   docker rm -f kiwix-serve-probe; docker volume rm kiwix-serve-probe-config
   ```
   Expected readiness signal: `kiwix-serve` listening line on 8080 (exact text UNVERIFIED; read the log).
4. `forgetool containers test --image kiwix-serve:3.7.0-1.1build2 --config ./apps/kiwix-serve/container-test.yaml`
5. Also run with a sample ZIM placed in a `/config` volume to confirm serving. A small ZIM is needed; not in the repo, so this step is manual and UNVERIFIED for now.
6. arm64 run only if the amd64 step fails in an arm64-specific way.

## 12. PR checklist

- Branch: `feat/add-kiwix-serve`
- Commit: `feat(kiwix-serve): add new container`
- PR title: `feat(kiwix-serve): add new container`
- Use `.github/PULL_REQUEST_TEMPLATE.md`; check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: tell the user that contributions need a signed CLA at https://cla-assistant.io/trueforge-org/containerforge; only the user can sign it. The `license/cla` check shows status.
- Say in the PR what was not tested (amd64 and arm64 builds, ZIM serving, empty-`/config` behaviour, if not run).
- `DOWNSTREAM_CHANGES.md`: not needed (not used as a FROM base).
