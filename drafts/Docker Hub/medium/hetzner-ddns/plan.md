# hetzner-ddns — implementation plan
> Source: ./draft.md · Target: apps/hetzner-ddns/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | Upstream's latest tag/release is `2.1` (2022-06-08), but master is 21 commits ahead (multi-record support, arm64 build, dependency bumps) and the Docker image `:latest` is built from master. Plan pins master commit `511c9118d12c74f559a39cd0c5ced9ce9147bba2` (2025-12-06), the commit the draft's Dockerfile link points at (`511c911`). Differs from the draft only in that the draft names no version. |
| Renovate | `datasource=git-refs depName=kutzilla/docker-hetzner-ddns packageName=https://github.com/kutzilla/docker-hetzner-ddns currentDigest=<sha>` (same style as the noVNC entry in this repo) |
| License | MIT (`LICENSE.md`, GitHub SPDX `MIT`) |
| Source URL | https://github.com/kutzilla/docker-hetzner-ddns |
| Per-arch download | None (no release assets). Compile from source: `go build ./cmd/hetzner-ddns` (`go.mod` module `matthias-kutz.com/hetzner-ddns`, `go 1.17`; deps `namsral/flag`, `robfig/cron/v3`). Tarball: `https://github.com/kutzilla/docker-hetzner-ddns/archive/<sha>.tar.gz`. |
| Checksum source | None for the archive; pinning the commit SHA is the integrity anchor, `go.sum` covers modules. |
| Upstream Dockerfile reviewed | Yes: `golang:1.19-alpine` build, `go build -o hetzner-ddns ./cmd/hetzner-ddns`, copied to `alpine`, `ENTRYPOINT ["/hetzner-ddns"]`. No ports, no volumes. |

Behaviour (from `pkg/conf/conf.go`, README):
- Env vars (via `namsral/flag`, which also accepts them as CLI flags): `ZONE_NAME` (required), `API_TOKEN` (required), `RECORD_TYPE` (required, `A` or `AAAA`), `RECORD_NAME` (default `@`), `RECORD_NAME_<NAME>` plus `RECORD_NAME_<NAME>_TTL` for several records, `TTL` (default 86400), `CRON_EXPRESSION` (default `*/5 * * * *`).
- If a required value is missing the program logs "The mandatory argument ... is missing" and exits 1.
- It looks up the public IP through ipify and edits records through `https://dns.hetzner.com/api/v1/...` with header `Auth-API-Token` (constants in `pkg/dns/hetzner.go`).

**Blocker:** Hetzner's status page (https://status.hetzner.com/incident/c2146c42-6dd2-4454-916a-19f07e0e5a44) says the DNS Console `dns.hetzner.com` and its legacy API were shut down (read-only 2026-05-20, removed by 2026-05-27); DNS now lives in the Hetzner Console / Cloud API with newly generated tokens. Upstream issue #32 "Moving from DNS API to Cloud API" is still open and master still targets `dns.hetzner.com`. A container built from upstream master will not be able to update records.

## 2. Target layout

```
apps/hetzner-ddns/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` (no config file; everything is env). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Final stage `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`; build stage `FROM --platform=$BUILDPLATFORM golang:1.26@sha256:6e59e17a20f13c102e49d82dffab66d41cffe6c266b225d82794328aea859ab5 AS build` (digest read from Docker Hub 2026-11-23). Reason: static Go binary calling HTTPS APIs; base already ships `ca-certificates` (upstream switched to Alpine to fix cert errors). Closest siblings: `apps/cloudflareddns` (DDNS updater with a runner-only test) and `apps/adguardhome-sync` (Go binary).

## 4. Dockerfile

1. Build stage: `ARG VERSION`, `ARG TARGETARCH`, `ENV GOCACHE=/tmp/go-cache GOPATH=/tmp/go CGO_ENABLED=0`. Fetch `https://github.com/kutzilla/docker-hetzner-ddns/archive/${VERSION}.tar.gz` (VERSION is the commit SHA), extract to `/src`, run `GOOS=linux GOARCH=${TARGETARCH} go build -trimpath -ldflags="-s -w" -o /out/hetzner-ddns ./cmd/hetzner-ddns`. Keep `LICENSE.md` as `/out/LICENSE.md`. Do not touch `go.mod`/`go.sum`.
2. Final stage: ubuntu `FROM`, `ARG VERSION`, `USER root`.
3. `COPY --from=build /out/hetzner-ddns /app/hetzner-ddns`, `COPY --from=build /out/LICENSE.md /usr/share/licenses/hetzner-ddns/LICENSE.md`, `chown -R root:root /app && chmod -R 755 /app`. No apt packages.
4. `ENV HOME=/tmp`.
5. `USER apps`, `COPY --chmod=0755 . /`.
6. No `EXPOSE` (no ports). `WORKDIR /config`. `VOLUME /config` is optional because the app stores nothing; declare it anyway for sibling consistency (cloudflareddns uses `WORKDIR /config`).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "hetzner-ddns" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=kutzilla/docker-hetzner-ddns packageName=https://github.com/kutzilla/docker-hetzner-ddns currentDigest=511c9118d12c74f559a39cd0c5ced9ce9147bba2
  default = "511c9118d12c74f559a39cd0c5ced9ce9147bba2"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/kutzilla/docker-hetzner-ddns" }
```
Plus the four standard targets and `group "default"` as in `apps/adguardhome-sync/docker-bake.hcl`. Image tag would be the long SHA; if the maintainers prefer, use `2.1` plus a note (UNVERIFIED which style they want for SHA-pinned apps; `apps/` already has a noVNC SHA example). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/kutzilla/docker-hetzner-ddns"
ports: []
env:
  - { name: ZONE_NAME, default: "", required: true }
  - { name: API_TOKEN, default: "", required: true }
  - { name: RECORD_TYPE, default: "A", required: false }
  - { name: RECORD_NAME, default: "@", required: false }
  - { name: TTL, default: "86400", required: false }
  - { name: CRON_EXPRESSION, default: "*/5 * * * *", required: false }
  - { name: TZ, default: "Etc/UTC", required: false }
volumes: []
dependencies: []
```
Settings rule: a `required: true` env var must have a non-empty default or be handled by `start.sh`; `start.sh` handles it (clear error, see section 7). `RECORD_TYPE` is required upstream, but `start.sh` supplies `A` so it is listed as optional with that default. Use the sibling block style for list entries. `RECORD_NAME_<NAME>` and `RECORD_NAME_<NAME>_TTL` are pattern variables and cannot be listed by fixed name; document them in the PR notes. No ports, no volumes (state-free).

## 7. start.sh

```bash
#!/usr/bin/env bash
: "${RECORD_TYPE:=A}"; export RECORD_TYPE
for v in ZONE_NAME API_TOKEN; do
  [[ -n "${!v:-}" ]] || { echo "hetzner-ddns: ${v} is required" >&2; exit 1; }
done
exec /app/hetzner-ddns
```
- Stateless and idempotent; nothing written to `/app` or `/config`; the token stays in the environment (not on the command line, so not in the process list).
- Env is read by the binary through `namsral/flag`; no mapping is needed. The upstream program runs one update immediately and then on the cron schedule (the README says every 5 minutes by default).
- Exiting 1 when required values are missing is deliberate (fail fast, same as upstream). The container test overrides the entrypoint so it never reaches this path (section 8).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
mainRunner:
  enabled: false
runners:
  - entrypoint: test -x /app/hetzner-ddns
  - entrypoint: bash -n /start.sh
filePaths:
  - /app/hetzner-ddns
  - /usr/share/licenses/hetzner-ddns/LICENSE.md
```
There are no ports in `settings.yaml`, so no tcp/http probe is needed. The test runs without env vars and the program exits 1 without them, so a main-runner wait would fail; the runner/`filePaths` style is the one `apps/cloudflareddns` uses. The code path that needs `ZONE_NAME`/`API_TOKEN` is covered by `filePaths` plus the manual run in section 11. UNVERIFIED: `bash -n /start.sh` as an entrypoint string is parsed by forgetool like the `test -x` form.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| None: the program keeps no state and writes no files | n/a |
| Go build cache (build stage only) | `/tmp/go-cache` |
| `$HOME` | `/tmp` |

Draft expectations (chart UID 0, `readOnlyRootFilesystem: false`, no persistence): we run as `apps` with a read-only rootfs; this is safe because nothing is written. Not privileged. Needs outbound HTTPS to the Hetzner API and ipify.

## 10. Risks, caveats and open questions

- **Blocker (new finding):** the upstream code calls `dns.hetzner.com/api/v1`, which Hetzner shut down in May 2026 (see section 1); upstream issue #32 is open. Recommend the maintainers do not merge this port until upstream (or a maintained fork) targets the Cloud API with Hetzner Console tokens. The plan below is correct for the code as it is today.
- Draft caveats kept: needs an API token plus zone/record names, and outbound internet; no UI, no ports.
- The tag `2.1` is older than the Docker `:latest` image (master); we follow master by SHA.
- IP detection goes through ipify (third-party); no way to disable it (UNVERIFIED: no env switch seen in `conf.go`).
- Upstream only supports a single `RECORD_TYPE` at a time (A or AAAA).
- No arm64 or musl issue: static Go build.

## 11. Build and test steps

```sh
cd apps/hetzner-ddns
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm hetzner-ddns:511c9118d12c74f559a39cd0c5ced9ce9147bba2   # expect "ZONE_NAME is required", exit 1
docker volume create hetzner-ddns-probe-config
docker run --rm -d --name hetzner-ddns-probe --read-only --tmpfs /tmp -v hetzner-ddns-probe-config:/config \
  -e ZONE_NAME=example.invalid -e API_TOKEN=dummy hetzner-ddns:<tag>
docker logs hetzner-ddns-probe    # expect an API error from Hetzner (token invalid), process starts the cron loop
forgetool containers test --image hetzner-ddns:<tag> --config ./apps/hetzner-ddns/container-test.yaml
docker rm -f hetzner-ddns-probe; docker volume rm hetzner-ddns-probe-config
```
Readiness signal: UNVERIFIED (the program's first log lines are not documented); success means the process keeps running with dummy credentials and logs a request failure rather than a config error. A real record update cannot be tested without a live Hetzner token and, per section 10, the legacy API is gone.

## 12. PR checklist

- Branch `feat/add-hetzner-ddns`; commit and PR title `feat(hetzner-ddns): add new container`; target `main`; use `.github/PULL_REQUEST_TEMPLATE.md`, only true boxes checked.
- `🤖 This PR is AI generated.` in the Notes section; mention the legacy-API blocker in the PR.
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Checklist: bake `--print` ok, `VERSION` in bake equals the Dockerfile `ARG`, rootless and read-only, `USER apps`.
- Untested until run: image build, arm64, runtime against the Hetzner API (the target API is shut down), the `go 1.17` module with the 1.26 toolchain.
