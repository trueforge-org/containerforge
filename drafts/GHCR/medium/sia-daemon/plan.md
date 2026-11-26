# sia-daemon — implementation plan
> Source: ./draft.md · Target: apps/sia-daemon/ · Difficulty: medium (upstream archived: hold recommended, see section 10) · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No daemon release exists. Latest GitHub release `v1.5.9` (2022-08-01) ships only Sia-UI assets (AppImage, dmg, exe, deb), no `siad` binary (`gh api repos/SiaFoundation/siad/releases/latest`). The chart uses `ghcr.io/siafoundation/siad:master` (draft), which is a moving tag. Pin a commit SHA if the port goes ahead (UNVERIFIED which SHA is current). |
| Upstream status | ARCHIVED. `archived: true`, last push 2025-05-05 (`gh api repos/SiaFoundation/siad`). The draft says it is superseded by newer Sia daemons; the successor is UNVERIFIED (not read). |
| Renovate | Only a git-refs pin is possible: `datasource=git-refs depName=https://github.com/SiaFoundation/siad currentValue=master` (precedent `apps/tvheadend`). Note: an archived repo receives no updates. |
| License | MIT (GitHub SPDX `MIT`). |
| Source URL | https://github.com/SiaFoundation/siad (module `go.sia.tech/siad`, `go 1.13` in go.mod). |
| Ready-made binary | None. Compile from source. `amd64`: compile. `arm64`: compile (UNVERIFIED that it builds on arm64). |
| Checksum source | None published for a build. Pin by commit SHA. |
| copy-from | No. The upstream image is `FROM alpine:latest` with a `golang:alpine` build (musl), which does not run on glibc Ubuntu. |
| Build (Makefile) | `static` target: `go build -trimpath -o release/ -tags='netgo' -ldflags='-s -w $(ldflags)' $(release-pkgs)` (`gh api .../contents/Makefile`). Upstream Dockerfile runs `git status` first to fix GIT_DIRTY detection in the Makefile. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/SiaFoundation/siad/66e7fc6/Dockerfile (WebFetch, commit 66e7fc6, as cited in the draft). Build `golang:alpine`, runtime `alpine:latest`, copies `/app/release` and CA certs to `/`. `ENV SIA_WALLET_PASSWORD=""` and `SIA_API_PASSWORD=""`. `EXPOSE 9981/tcp 9982/tcp 9983/tcp`. `VOLUME ["/sia-data"]`. No USER (runs as root). `ENTRYPOINT ["/siad", "--disable-api-security", "-d", "/sia-data", "--api-addr", ":9980"]`. |
| Ports | API `9980/tcp` (from the ENTRYPOINT `--api-addr`, not in upstream EXPOSE); gateway `9981/tcp`; host RHP2 `9982/tcp`; host RHP3 `9983/tcp` (upstream EXPOSE). The draft's `9982` host and `9981` gateway are confirmed. |
| Data path | `/sia-data` (upstream VOLUME and `-d` flag). |
| Auth | Upstream passes `--disable-api-security`, so the API has no auth even though `SIA_API_PASSWORD` is set empty. Upstream comment and flag conflict (fact from the Dockerfile). |
| Wallet | `SIA_WALLET_PASSWORD` auto-unlocks the wallet when set. A wallet must be created or imported on first run (draft, UNVERIFIED on the daemon side). |
| Dependencies | None. |

## 2. Target layout

Files in `apps/sia-daemon/`:
- `Dockerfile`: required.
- `docker-bake.hcl`: required.
- `settings.yaml`: required.
- `container-test.yaml`: required.
- `start.sh`: required (replaces the upstream ENTRYPOINT; starts `siad` with the data dir on `/config`).
- `defaults/`: not needed.

Never use `root/`. `DOWNSTREAM_CHANGES.md`: not needed.

## 3. Base image

- Build stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, with `golang-go` from apt (as in `apps/pwndrop`). Go version for `go 1.13` modules: apt version UNVERIFIED; any Go 1.13+ toolchain should build, but verify.
- Final stage: the same ubuntu base. The upstream alpine runtime is not used.
- Closest sibling: `apps/pwndrop` (Go build stage, ubuntu runtime).

## 4. Dockerfile

1. Stage `build` `FROM <ubuntu>`, `ARG VERSION` (commit SHA), `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends build-essential golang-go git make ca-certificates`. Check `git` is in the base before adding it.
3. `ENV GOCACHE=/tmp/go-build GOPATH=/tmp/go GOFLAGS=-mod=mod`.
4. Fetch by SHA: `curl -fL -o /tmp/siad.tar.gz https://github.com/SiaFoundation/siad/archive/${VERSION}.tar.gz`, extract to `/tmp/src --strip-components=1`. Check the tarball lacks `.git`; if so, `make static` GIT_DIRTY needs a `git init` with a commit in `/tmp/src` (mirror the upstream `git status` workaround).
5. `cd /tmp/src && make static` → `/tmp/src/release/siad`. Copy to `/app/siad/siad`.
6. License: `install -D /tmp/src/LICENSE /usr/share/licenses/sia-daemon/LICENSE`.
7. Final stage `FROM <ubuntu>`, `USER root`, `COPY --from=build /app/siad/ /app/siad/`, `COPY --from=build /usr/share/licenses/sia-daemon /usr/share/licenses/sia-daemon`, `chown -R apps:apps /app/siad && chmod -R 755 /app/siad`.
8. `ENV HOME=/config GOCACHE=/tmp/go-build`. `SIA_WALLET_PASSWORD` and `SIA_API_PASSWORD` are NOT set as image ENV (no empty defaults; see section 9).
9. Tail: `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 9980 9981 9982 9983`, `VOLUME /config`, `WORKDIR /config`.

Version alignment: `ARG VERSION` equals the `docker-bake.hcl` default SHA.

## 5. docker-bake.hcl

- `APP = "sia-daemon"`, `VERSION = "<commit SHA>"` with `// renovate: datasource=git-refs depName=https://github.com/SiaFoundation/siad currentValue=master`, `LICENSE = "MIT"`, `SOURCE = "https://github.com/SiaFoundation/siad"`.
- Four standard targets plus `group "default" { targets = ["image-local"] }`, as in `apps/adguardhome-sync`.
- Validate: `cd apps/sia-daemon && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/SiaFoundation/siad"
ports:
  - port: 9980
    protocol: tcp
    required: true
  - port: 9981
    protocol: tcp
    required: false
  - port: 9982
    protocol: tcp
    required: false
  - port: 9983
    protocol: tcp
    required: false
env:
  - name: SIA_WALLET_PASSWORD
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- `SIA_API_PASSWORD` is omitted unless the API-auth path is implemented (it is not honored by upstream's ENTRYPOINT because of `--disable-api-security`; see R2).
- Data path: `/config` in the port (the draft says the chart's `datadirectory` is `/sia-data`; decide whether the image keeps `/sia-data` as a volume or maps it to `/config`, see section 9).

## 7. start.sh

- `#!/usr/bin/env bash`, `mkdir -p /config/sia`.
- Run `exec /app/siad/siad -d /config/sia --api-addr 0.0.0.0:9980 --gateway-addr :9981 --rpc-addr :9982 --host-addr :9983` (flag names UNVERIFIED for this commit; check `siad --help` in the build before writing). Do NOT pass `--disable-api-security` unless the port adopts upstream's no-auth behaviour, which is a decision for the maintainer (R2).
- Export `SIA_WALLET_PASSWORD` only when set; never echo it to logs or argv (value must not appear in the process list; pass via env).
- Idempotent: no seeding; the daemon creates its data in `/config/sia`.
- Never write to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '9980'
- port: '9981'
- port: '9982'
- port: '9983'
http:
- port: '9980'
  path: /daemon/version
filePaths:
- /app/siad/siad
- /usr/share/licenses/sia-daemon/LICENSE
```

- Every port in settings.yaml has a `tcp` probe.
- `/daemon/version` is an API path to be confirmed for this commit (UNVERIFIED). Replace with the actual readiness endpoint before running tests.
- `timeoutSeconds` is an estimate; the daemon may take longer on first start. Compare with sibling apps of the same family.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/sia-data` (upstream VOLUME, `-d` flag) | `/config/sia` via `start.sh`. Keep the chart's `datadirectory` mapping in mind for downstream use. |
| `/app` (binary) | Read-only at runtime. Build-time only. |
| Go cache, temp | `/tmp`. |
| Root user | Upstream runs as root. The image runs as `apps` (UID 568). Ports 9980-9983 are above 1024, so no capability is needed. |
| `SIA_WALLET_PASSWORD` in image ENV | Not set in the image. Read from env only at runtime. |

## 10. Risks, caveats and open questions

- R1. HOLD RECOMMENDED. The upstream repo is archived (2025-05-05) and superseded (per draft; successor UNVERIFIED). No maintained daemon release exists. Confirm with the user whether a successor (for example a different Sia daemon repository) should be ported instead before building this one.
- R2. `--disable-api-security` in the upstream ENTRYPOINT means the API is unauthenticated, and the `SIA_API_PASSWORD` comment conflicts with it. Decide whether the port keeps this behaviour (not recommended) or drops the flag and implements API auth.
- R3. Ports: the API binds `:9980`, which is not in upstream EXPOSE; the gateway `9981` is. Confirm the RHP3 `9983` port exists in this commit.
- R4. Image tag `ghcr.io/siafoundation/siad:master` (chart) is a moving tag; whether it still publishes after archive is UNVERIFIED.
- R5. Wallet creation/import and blockchain sync are manual and long (draft, inferred). The test must not depend on a synced chain; keep the test to process start and port open.
- R6. The Go toolchain for a `go 1.13` module on Ubuntu 26.04 is UNVERIFIED; the build may fail.
- R7. musl: upstream image is alpine; this port is glibc Ubuntu, so no `COPY --from` of the upstream binary.
- No arm64 binary exists; arm64 is untested.
- Blocker (recommended): archived upstream (see R1).

## 11. Build and test steps

From `apps/sia-daemon/`:
1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name sia-daemon-probe --read-only --tmpfs /tmp -v sia-daemon-probe-config:/config sia-daemon:<SHA>` then `docker logs -f sia-daemon-probe`. Expected readiness signal: the API listening line on 9980 (UNVERIFIED wording).
4. `forgetool containers test --image sia-daemon:<SHA> --config ./container-test.yaml`.
5. Cleanup: `docker rm -f sia-daemon-probe; docker volume rm sia-daemon-probe-config`.
6. arm64 only if amd64 fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-sia-daemon`, commit `feat(sia-daemon): add new container`, PR title the same.
- Note in the PR that the upstream is archived and that the port was built against a pinned commit.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; keep sections and checkboxes; check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it; the `license/cla` check shows status.
- Say what is not tested: arm64, wallet and sync behaviour, the API auth decision, anything not built locally.
- Check `docker buildx bake --print` was run and passed.
