# twtxt — implementation plan
> Source: ./draft.md · Target: apps/twtxt/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
|---|---|---|
| Latest stable version | UNVERIFIED: the git.mills.io releases page returned a proof-of-work browser check, so no tag or date was read. The draft's chart image is `ghcr.io/nicholaswilde/twtxt:version-0.1.1`. | https://git.mills.io/prologic/twtxt/releases (blocked), draft.md |
| Renovate | UNVERIFIED: `datasource=git-tags` against `https://git.mills.io/prologic/twtxt` is the likely choice, but it is not confirmed. The GitHub repo `prologic/twtxt` returns 404, so `github-releases` cannot be used. | `gh api repos/prologic/twtxt` returned 404 |
| License (SPDX) | UNVERIFIED | not reached |
| Source | https://git.mills.io/prologic/twtxt (primary); the upstream Dockerfile downloads `https://github.com/prologic/twtxt/archive/refs/tags/${FILENAME}` | upstream Dockerfile |
| Per-arch binary | None published. Build from source on amd64 and arm64. | draft.md, releases page blocked |
| Checksum source | The upstream Dockerfile verifies a sha256 passed as `CHECKSUM` build arg, then `sha256sum -c`. Our build should pin the sha256 of the source tarball we fetch, and the upstream value is not confirmed. | https://raw.githubusercontent.com/nicholaswilde/docker-twtxt/3618126/Dockerfile |
| Upstream Dockerfile (nicholaswilde/docker-twtxt @3618126) | Stage `dl`: `FROM golang:1.16.5-alpine3.14`. Runs `make deps`, `go mod download`, `make server VERSION=... COMMIT=HEAD`, produces `/app/twtd`. Final: `FROM linuxserver/baseimage-alpine:3.14` (musl), installs ffmpeg and ca-certificates, `VOLUME /data /config`, `EXPOSE 8000`, `ENV GODEBUG=netdns=cgo`, creates `/data` and `/config/feeds`. No USER, ENTRYPOINT or CMD in the Dockerfile; startup is in `root/`, which was not fetched. | https://raw.githubusercontent.com/nicholaswilde/docker-twtxt/3618126/Dockerfile |
| Ports | 8000 (EXPOSE in upstream) | upstream Dockerfile |
| Env vars | Only `GODEBUG=netdns=cgo` is confirmed. Application env vars: UNVERIFIED (read `twtd --help` and the upstream `root/` scripts). | upstream Dockerfile |
| Write paths | `/data`, `/config/feeds` (upstream). Config file: UNVERIFIED path and format. | upstream Dockerfile |
| Dependencies | None | draft.md |

Note: the upstream runtime is Alpine (musl) and installs ffmpeg. Our final stage is glibc Ubuntu, so ffmpeg must come from apt only if the server really needs it. This is UNVERIFIED: check whether twtd calls ffmpeg at runtime.

## 2. Target layout

Files in `apps/twtxt/`:
- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required: seeds config and `exec`s twtd)

Not needed: `defaults/` is only needed if a default config file is shipped; the plan seeds the config from the start script instead, so it is omitted unless the config must be a file copied from the image. `etc/`, `health/`, `app/`, `root/` are not needed. Never use `root/`.

`DOWNSTREAM_CHANGES.md` is not needed: twtxt is not a `FROM` base for any app.

## 3. Base image

Final stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.

Why: the draft says ubuntu alone is enough, and the Go server is a single binary, so ubuntu is the right final base (see the go-runtime rules).

Build stage: `golang:<version>` with the tag UNVERIFIED. No Go sibling app exists in `apps/`. Pick a current supported Go tag (check on the Docker Hub tag list before writing the Dockerfile) and make sure the Go version meets the twtxt `go.mod` directive, which is UNVERIFIED.

Closest sibling for layout: `apps/adguardhome-sync` (prebuilt binary on ubuntu, `USER apps`, `COPY --chmod=0755 . /`).

## 4. Dockerfile

Two stages. The build stage compiles, the final stage copies the binary.

1. `FROM golang:<version> AS build`
2. `ARG VERSION`, `ARG CHECKSUM` (no defaults in the build stage, bake supplies them).
3. Download the tagged source archive from git.mills.io (or the GitHub archive if it resolves; see Risks), then `echo "${CHECKSUM}  twtxt-${VERSION}.tar.gz" | sha256sum -c -`, then extract with `--strip-components 1` into `/src`.
4. `make deps` (or `go mod download`), then `make server VERSION="${VERSION}" COMMIT="${COMMIT}"`. The output is `twtd`.
5. Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:...` (digest from section 3).
6. `ARG VERSION`, `ARG TARGETARCH`, `USER root` only if apt is needed (it is not, unless ffmpeg is confirmed).
7. `COPY --from=build /src/twtd /app/twtd` and the license file to `/usr/share/licenses/twtxt/`.
8. `chown` is not needed because `/app` is read-only at runtime and owned by root; set `chmod 0755` on the binary.
9. `ENV HOME=/config` and `GOCACHE` not needed in the final stage. Any cache env must point to `/tmp`.
10. `USER apps`, then `COPY --chmod=0755 . /`, then `EXPOSE 8000`, `VOLUME /config`, `CMD ["/start.sh"]`.

Do not install Go in the final stage. Do not write to `/app`.

## 5. docker-bake.hcl

- `target "docker-metadata-action" {}`
- `variable "APP" { default = "twtxt" }`
- `variable "VERSION" { // renovate: datasource=git-tags depName=... versioning=loose  default = "<verified>" }` — renovate line UNVERIFIED (section 1). Use `versioning=loose` because the upstream tags are not confirmed to be strict semver.
- `variable "LICENSE" { default = "<UNVERIFIED SPDX>" }`
- `variable "SOURCE" { default = "https://git.mills.io/prologic/twtxt" }`
- `variable "COMMIT"` is not needed unless the Makefile requires it; pass `HEAD` as in upstream only if required.
- Standard targets: `image` (args VERSION, CHECKSUM, labels source and licenses), `image-local` (`output = ["type=docker"]`, tag `${APP}:${VERSION}`), `image-all` (linux/amd64, linux/arm64), `group "default" { targets = ["image-local"] }`.
- `CHECKSUM` must be a variable with the verified sha256 of the source tarball. Add it with a comment that it is the sha256 of the tag archive.
- Validate with `docker buildx bake --print` from `apps/twtxt`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://git.mills.io/prologic/twtxt"
ports:
  - port: 8000
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- `upstream_env_url` must equal `SOURCE`.
- Env vars: only TZ is safe to list. Add application env vars (for example the public base URL, which the draft says is needed for feed links) only after they are confirmed in the twtd source or the upstream `root/` scripts. UNVERIFIED names must not be added.
- `dependencies`: none.
- Ports: only 8000 (upstream EXPOSE). Confirm the port in twtd config defaults before finalising.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- Seed the config only when missing: `[[ -f /config/config ]] || cp <seed source> /config/config` (a seed file would need `defaults/`, which section 2 omits; the file name and path are UNVERIFIED; if the default config is generated by twtd, call its init command instead, only when `/config` has no config file).
- Create `/config/feeds` with `mkdir -p` when missing (upstream creates it at build time, we must create it at runtime because `/config` may be empty).
- Never write into `/app`.
- `exec /app/twtd` with the flags the server needs (confirm the flags with `twtd --help`). Bind to `0.0.0.0` on port 8000 (the start script rules say to listen on all interfaces, so check the default bind address).
- Environment reads: only names confirmed in section 6.
- Caches: none expected. If Go or the server writes temp files, point them to `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
filePaths:
- /app/twtd
tcp:
- port: '8000'
```

- Every port in settings.yaml has a tcp probe (port 8000). The test runs with no env, so the config seeding path runs on an empty `/config`.
- `timeoutSeconds: 180` is a top-level key (UNVERIFIED value: `apps/adguardhome-sync` sets none; adjust after the first run).
- Add an http probe only after `/` is confirmed to return 200 on a fresh `/config` (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

Upstream path remaps:
- `/data` (upstream VOLUME) → not used. Everything persistent goes to `/config` (feeds, config). Remap the server's data dir to `/config` in start.sh or in config (the exact setting is UNVERIFIED).
- `/config/feeds` → `/config/feeds` (kept, created at runtime).
- `/app/twtd` stays in `/app` and is read-only at runtime.

Security expectation reconciliation (draft says: non-root no, read-only no, privileged no):
- Target: `USER apps` (non-root), read-only rootfs compatible. This deviates from the TrueCharts chart on purpose; the chart values are a starting point only.
- Privileged: no.
- Extra persistence: none. `/data` from upstream is dropped.

## 10. Risks, caveats and open questions

- Upstream source archive: the upstream Dockerfile uses `https://github.com/prologic/twtxt/archive/refs/tags/...`, but `gh api repos/prologic/twtxt` returned 404. Check whether that archive URL resolves at all. If it does not, use the git.mills.io source instead and pin its sha256 (UNVERIFIED).
- Upstream runs on Alpine (musl) with a Go 1.16 build. Our build uses a current Go, which must compile the repo's `go.mod` without changes (UNVERIFIED).
- ffmpeg: the upstream final image installs it; whether twtd needs it at runtime is UNVERIFIED.
- Latest release, license, renovate rule, startup flags, config path and env vars are all UNVERIFIED (section 1).
- The draft caveats still stand (inferred): a config file must exist before the server works, and the public base URL must be set for feed links.
- Blocker check: no musl-only code path is known; no GPU or privileged need; arm64 is a source compile (same as amd64), so both arches are feasible.

## 11. Build and test steps

From `apps/twtxt`:
1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Clean run with an empty volume:
   ```sh
   docker volume create twtxt-probe-config
   docker run --rm -d --name twtxt-probe --read-only --tmpfs /tmp \
     -v twtxt-probe-config:/config ${APP}:${VERSION}
   docker logs -f twtxt-probe
   ```
   Pass: the container is still running, the logs show a listening line for port 8000 (the exact text is UNVERIFIED; use the port check if no log line appears), and there are no fatal errors.
4. Cleanup: `docker rm -f twtxt-probe; docker volume rm twtxt-probe-config`.
5. `forgetool containers test --image twtxt:<version> --config ./apps/twtxt/container-test.yaml`. If forgetool is not available locally, run step 3 and check port 8000 and `/app/twtd` by hand.
6. Repeat step 3 with an existing `/config` to confirm the restart path.
7. arm64: `image-all` build only after amd64 passes; the build is slow, so state it in the PR if it is not run.

Not run in this planning step: no docker builds were done.

## 12. PR checklist

- Branch: `feat/add-twtxt`
- Commit: `feat(twtxt): add new container`
- PR title: `feat(twtxt): add new container`
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Only check what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- Say what was not tested: the upstream archive URL, latest version, license, config format, env vars and arm64 build are UNVERIFIED unless confirmed during the build.
- Not applicable: DOWNSTREAM_CHANGES.md (not a base image).
