# watchyourlan — implementation plan
> Source: ./draft.md · Target: apps/watchyourlan/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable | 2.1.4, released 2025-09-10 | https://github.com/aceberg/WatchYourLAN/releases/tag/2.1.4 |
| renovate | `datasource=github-releases depName=aceberg/WatchYourLAN versioning=semver` | derived (GitHub release tags) |
| License | MIT, Copyright (c) 2022 aceberg | https://raw.githubusercontent.com/aceberg/WatchYourLAN/main/LICENSE |
| Source | https://github.com/aceberg/WatchYourLAN | draft |
| Per-arch assets | Release lists `.deb`, `.rpm`, `.apk`, `.tar.gz`; arches amd64, i386, arm_v5/6/7, arm64. Exact asset names: UNVERIFIED (release asset list did not load). Draft names `watchyourlan_2.1.4_linux_{amd64,arm64}.apk` are UNVERIFIED. | https://raw.githubusercontent.com/aceberg/WatchYourLAN/ca9f644bccba41cdb3db952b828137fa53c2f640/README.md |
| Checksum source | UNVERIFIED: no checksum file seen on the fetched pages | — |
| Upstream Dockerfile | Multi-stage. Builder `golang:alpine` + `tonistiigi/xx`; `cd backend` module; `CGO_ENABLED=0 xx-go build -ldflags='-w -s' -o /WatchYourLAN ./cmd/WatchYourLAN`. Final `alpine`: `WORKDIR /app`, `apk add --no-cache arp-scan tzdata`, `mkdir /data`, `ENTRYPOINT ["./WatchYourLAN"]`. No `USER` (runs as root). | https://raw.githubusercontent.com/aceberg/WatchYourLAN/ca9f644bccba41cdb3db952b828137fa53c2f640/Dockerfile |
| Runtime deps | `arp-scan`, `tzdata` (apt equivalents on ubuntu) | README |
| Env vars | `PORT` (default 8840), `IFACES`, `ARP_ARGS`, `ARP_STRS`, `ARP_STRS_JOINED`, `INFLUX_ENABLE`, `INFLUX_ADDR` | README env table |
| Ports | 8840/tcp web GUI | README |
| Config/data path | `-d` flag, default `/data/WatchYourLAN` | README |
| Host networking | README: WYL needs `host` network mode to work | README |
| arm64 | Yes (README lists arm64) | README |
| Dependencies | none (no database; SQLite/local files by default) | README |

Draft version tag `2.1.4` matches the release tag. Draft container image `ghcr.io/aceberg/watchyourlan:2.1.4` is the upstream image the chart uses today; its Dockerfile is the one above (commit ca9f644).

## 2. Target layout

Files in `apps/watchyourlan/`:
- `Dockerfile`: required.
- `docker-bake.hcl`: required.
- `settings.yaml`: required.
- `container-test.yaml`: required.
- `start.sh`: required (seeds `/config`, `exec`s the binary).
- `defaults/`: only if a default config is seeded (`defaults/config.yaml`). Reason: upstream config is generated on first run; if the app creates it itself, omit.
- `DOWNSTREAM_CHANGES.md`: not needed (not used as a `FROM` base).
- Never use `root/`.

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` (final stage).
- Go build stage: `golang:<ver>` pinned to the version used by an existing Go app in `apps/` (UNVERIFIED: `grep -l golang apps/*/Dockerfile` finds no sibling with a Go build stage in this repo, so there is no repo precedent for the tag; choose one matching `backend/go.mod` and set `GOCACHE=/tmp/go-build` in the build stage).
- Closest sibling: `apps/adguardhome-sync` (prebuilt binary on ubuntu, `USER apps`, `COPY --chmod=0755 . /`). No sibling in `apps/` has a Go build stage (grep found none), so follow `.github/instructions/go-runtime.instructions.md` directly.
- Reason: Go builds in a dedicated stage, copied into the ubuntu runtime. The upstream Alpine (`apk`) runtime cannot be used on ubuntu.

## 4. Dockerfile

Recommended approach: build from source in a Go build stage (the upstream's own method, glibc-compatible because `CGO_ENABLED=0`), instead of extracting the upstream `.apk`. Reason: the `.apk` names and checksum are unverified, while the source tag is confirmed.

Steps:
1. `ARG VERSION` and `ARG TARGETARCH`, `ARG TARGETPLATFORM` (match `docker-bake.hcl` `VERSION` default `2.1.4`).
2. Build stage: `FROM --platform=$BUILDPLATFORM golang:<ver> AS build`; `git clone --depth 1 --branch ${VERSION} https://github.com/aceberg/WatchYourLAN /src` (or `curl` the tag tarball, then verify its SHA-256 if upstream publishes one; otherwise record that no checksum exists).
3. `cd /src/backend && CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH go build -ldflags='-w -s' -o /out/WatchYourLAN ./cmd/WatchYourLAN`. Do not modify `go.mod`/`go.sum`.
4. Runtime stage (ubuntu): `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
5. `apt-get install -y --no-install-recommends arp-scan tzdata` with the version pinned and checked against `VERSION` as in `apps/valkey` (pin the arp-scan version found at build time; record it in the Dockerfile comment-free form via `ARG`).
6. `COPY --from=build /out/WatchYourLAN /app/WatchYourLAN` and `chmod 0755`.
7. Licence: `COPY` upstream `LICENSE` to `/usr/share/licenses/watchyourlan/LICENSE` (build stage: `cp /src/LICENSE /out/LICENSE`).
8. `ENV HOME=/config`, `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8840`, `VOLUME /config`.
9. Caches: none needed for a prebuilt binary. Build cache stays in the build stage only.

## 5. docker-bake.hcl

- `variable "APP" { default = "watchyourlan" }`.
- `variable "VERSION" { // renovate: datasource=github-releases depName=aceberg/WatchYourLAN versioning=semver  default = "2.1.4" }`.
- `variable "LICENSE" { default = "MIT" }`.
- `variable "SOURCE" { default = "https://github.com/aceberg/WatchYourLAN" }`.
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all`, and `group "default"` with `image-local`.
- Validate with `docker buildx bake --print` from `apps/watchyourlan`.

## 6. settings.yaml

- Schema header and `schema_version: 1`.
- `upstream_env_url: "https://github.com/aceberg/WatchYourLAN"`.
- `ports`: `- port: 8840, protocol: tcp, required: true`.
- `env`:
  - `PORT`, default `"8840"`, required false.
  - `IFACES`, default `""`, required false (interfaces to scan; empty uses arp-scan default).
  - `ARP_ARGS`, default `""`, required false.
  - `INFLUX_ENABLE`, default `"false"`, required false (only if the influx path is exercised; otherwise omit).
  - `TZ`, default `"Etc/UTC"`, required false (sibling convention).
  - Do not list `ARP_STRS` / `ARP_STRS_JOINED` / `INFLUX_ADDR` unless `start.sh` passes them through (they are read by the app, so they may be listed; keep the list to what the README documents).
- `volumes`: `- path: /config, required: true`.
- `dependencies`: none. `opt_dependencies`: none (the draft's optional PostgreSQL is not used by the README; SQLite is the default).

## 7. start.sh

- Shebang `#!/usr/bin/env bash`.
- Seed nothing unless a default config is needed. Seed `/config/WatchYourLAN` only when missing.
- Map env to the app's flags: `exec /app/WatchYourLAN -d /config/WatchYourLAN` (the `-d` flag is documented; the exact way to pass `PORT`/`IFACES` is env, read by the binary).
- Bind address: the web GUI must listen on 0.0.0.0 (verify at run time; README does not state it: UNVERIFIED).
- Never write to `/app`. Caches none.
- Final line: `exec /app/WatchYourLAN ...` for signal handoff.

## 8. container-test.yaml

- Schema header from `apps/adguardhome-sync/container-test.yaml`.
- `tcp: - port: '8840'`.
- `http`: probe `/` on 8840 once the web UI is confirmed (UNVERIFIED path; use the tcp probe until confirmed).
- `timeoutSeconds`: take the value from a sibling of the same family (Go + ubuntu).
- `filePaths`: none required by default; add `/app/WatchYourLAN` existence check.
- Note: test runs with no env; required-env paths are not tested by this suite. The `arp-scan` discovery needs `NET_RAW` and host networking, which the test environment may not provide; if the scan fails, the readiness signal in logs may be missing. Treat as a risk (section 10).

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: `/data/WatchYourLAN` (config dir `-d`). Remapped to `/config/WatchYourLAN` via `start.sh`.
- Upstream runs as root. The ContainerForge runtime is `USER apps`. `arp-scan` requires raw sockets (`CAP_NET_RAW`). Options:
  1. Grant the file capability at build time: `setcap cap_net_raw+ep /usr/sbin/arp-scan` (root stage), so the non-root user can scan. UNVERIFIED that this works on the ubuntu base; test it.
  2. Chart-side `NET_RAW` capability and `hostNetwork` (what the TrueCharts chart does today). Not possible in this repo; flag to the user.
- Read-only rootfs: `/app` untouched at runtime. `/tmp` for scratch. `/config` only for config/state.
- Chart expectations (draft): non-root no, read-only no, `hostNetwork true`, `NET_RAW`, extra `/data` persistence. Target: non-root yes (option 1), read-only yes (no `/app` writes), host networking remains required by design.

## 10. Risks, caveats and open questions

- Host networking: ARP discovery only sees the segment the container is attached to. Under bridge networking it finds nothing useful. Blocker for a typical test run.
- Raw socket capability: see section 9. Without `CAP_NET_RAW` arp-scan fails.
- Asset names: draft `.apk` file names UNVERIFIED. Plan uses source build to avoid them.
- arm64: upstream lists arm64, so the build stage can cross-compile; not yet tested.
- Checksum: none published; record the source tag SHA in the PR.
- Draft caveat "PostgreSQL optional": not confirmed. README says SQLite default; PostgreSQL not in the env table.
- Draft caveat "ARP only sees the attached LAN": confirmed in README (host network).
- Blockers: none that prevent a build; the runtime needs host networking and `CAP_NET_RAW`, so a full functional test may not be feasible in a single container. If this is confirmed, the build-test protocol's DB-dependent exception does not apply (no DB dependency): document the narrowed assertions in `container-test.yaml` and say so in the PR.

## 11. Build and test steps

From `apps/watchyourlan`:
1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name watchyourlan-probe --read-only --tmpfs /tmp -p 8840:8840 --cap-add NET_RAW --network host -v watchyourlan-probe-config:/config watchyourlan:2.1.4` (host network required by the app; drop `-p` when using host network).
4. `docker logs -f watchyourlan-probe` until idle. Expected readiness signal: the web GUI listening line on 8840 (exact text UNVERIFIED; use `ss -ltn` port check if the log line is absent).
5. `docker rm -f watchyourlan-probe; docker volume rm watchyourlan-probe-config`.
6. `forgetool containers test --image watchyourlan:2.1.4 --config ./container-test.yaml`.
7. Round limit: 10. If the arp-scan step fails for environment reasons (no raw sockets), record it and do not weaken the test.

## 12. PR checklist

- Branch `feat/add-watchyourlan`; commit `feat(watchyourlan): add new container`.
- PR title: `feat(watchyourlan): add new container`.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- Use `.github/PULL_REQUEST_TEMPLATE.md` and keep its checkboxes; check only what applies.
- Say what was not tested: the host-network and `NET_RAW` behaviour, arm64 runtime, and any asset names that could not be verified. Do not check "Built container locally" unless the build ran.
