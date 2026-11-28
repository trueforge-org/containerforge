# linkwallet — implementation plan
> Source: ./draft.md · Target: apps/linkwallet/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `0.1.1` (tag `v0.1.1`, 2025-05-04). Latest release; same as the draft and the chart tag. |
| Renovate | `datasource=github-releases depName=tardisx/linkwallet versioning=semver`. The GitHub repo is archived (2025-05-23) and the README says the project moved to https://code.ppl.town/justin/linkwallet; the Forgejo releases page lists the same `v0.1.1` as latest, so there is currently nothing newer to track. |
| License | `MIT` (GitHub reports MIT; the tarball ships `LICENSE`, "Copyright (c) 2022 Justin Hawkins"). |
| Source (`SOURCE`) | https://github.com/tardisx/linkwallet |
| Downloads | amd64: `https://github.com/tardisx/linkwallet/releases/download/v0.1.1/linkwallet_Linux_x86_64.tar.gz`. arm64: `https://github.com/tardisx/linkwallet/releases/download/v0.1.1/linkwallet_Linux_arm64.tar.gz`. Each tarball holds `linkwallet`, `LICENSE`, `README.md`. The amd64 binary is a statically linked, stripped ELF (checked with `file`); `.goreleaser.yaml` builds all architectures with `CGO_ENABLED=0`. The arm64 tarball hash also matches (re-checked 2026-11-25). |
| Checksum source | Upstream `linkwallet_0.1.1_checksums.txt` in the release (sha256): amd64 `cc0710ac78a0b6a4d830b438ac4335593e6840234cb0feebdbfd29ad143ee9d4`, arm64 `ce4aa3c0e2494a8e02c4fa7949b5adf2fc3d5b18f109395c3efd0d648ea49f85`. I downloaded the amd64 tarball and its hash matches. |
| CLI | `linkwallet -db-path <file>` is mandatory (`log.Fatal` when empty). The DB is a bolthold file at that path and a Bleve index at `<path>.bleve` (created if missing). |
| Port / bind | README: default `8080`, change with the `PORT` environment variable. The server is `gin.Default().Run()`, which reads `PORT` and binds all interfaces. |
| Other env | `GIN_MODE=release` is read by gin to silence debug output (gin behaviour, not documented by linkwallet). The README does not list other env vars. |
| Auth | None found in README or `main`; settings such as `BaseURL` are in the web config page (stored in the DB). UNVERIFIED whether any login exists. |
| Upstream Dockerfile reviewed | https://github.com/tardisx/linkwallet/blob/main/Dockerfile (`FROM alpine:3.16`, `ENTRYPOINT ["/linkwallet"]`, `COPY linkwallet /`). The sample compose uses `entrypoint: ['/linkwallet','-db-path','/data/linkwallet.db']` and a `/data` volume. |

## 2. Target layout

```
apps/linkwallet/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

- No `defaults/`, `etc/`, `scripts/`, `health/`: the app creates its own DB. No `root/`. No `DOWNSTREAM_CHANGES.md`.
- Closest sibling: `apps/adguardhome-sync` (Go release tarball on ubuntu, `start.sh` with `exec`). The Go rules (build stage) do not apply because we use the published binary, not a compile.

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a
```

Static Go binary needs no runtime; `curl`, `tar` and `ca-certificates` (needed for page scraping over HTTPS) are in the base.

## 4. Dockerfile

1. `FROM` as above; `ARG VERSION`; `ARG TARGETARCH`.
2. No checksum ARGs: the build fetches the release's checksum file (step 5), so a `VERSION` bump needs no hand-edited hashes.
3. `USER root`.
4. `ENV HOME=/config`.
5. One `RUN set -eux` step:
   - arch map: `case "${TARGETARCH}" in amd64) a=x86_64;; arm64) a=arm64;; *) exit 1;; esac`
   - `curl -fsSLo /tmp/lw.tgz "https://github.com/tardisx/linkwallet/releases/download/v${VERSION}/linkwallet_Linux_${a}.tar.gz"`
   - `curl -fsSLo /tmp/checksums.txt "https://github.com/tardisx/linkwallet/releases/download/v${VERSION}/linkwallet_${VERSION}_checksums.txt"` then `(cd /tmp && grep " linkwallet_Linux_${a}.tar.gz\$" checksums.txt | sha256sum -c -)`
   - `mkdir -p /tmp/lw /usr/share/licenses/linkwallet && tar xzf /tmp/lw.tgz -C /tmp/lw`
   - `install -m 0755 /tmp/lw/linkwallet /app/linkwallet && install -m 0644 /tmp/lw/LICENSE /usr/share/licenses/linkwallet/LICENSE`
   - `chown -R apps:apps /app && rm -rf /tmp/*`
6. `COPY --chmod=0755 . /`
7. `EXPOSE 8080`, `VOLUME /config`.
8. Final `USER apps`.

No apt packages, so nothing to pin.

## 5. docker-bake.hcl

- `APP` = `linkwallet`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-releases depName=tardisx/linkwallet versioning=semver
  default = "0.1.1"
  ```
- `LICENSE` = `MIT`, `SOURCE` = `https://github.com/tardisx/linkwallet`
- Four standard targets + `group "default"` copied from `apps/adguardhome-sync/docker-bake.hcl`; `image-all` = amd64 + arm64.
- `docker buildx bake --print` must pass.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/tardisx/linkwallet"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: DB_PATH
    default: "/config/linkwallet.db"
    required: false
  - name: GIN_MODE
    default: "release"
    required: false
  - name: PORT
    default: "8080"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`PORT` and `GIN_MODE` are read by the app/gin. `DB_PATH` is read only by our `start.sh` and is passed to `-db-path`; it lets the chart keep an existing DB on a `/data` mount. No `dependencies:` (draft: none; embedded DB).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export GIN_MODE="${GIN_MODE:-release}"
export PORT="${PORT:-8080}"
DB_PATH="${DB_PATH:-/config/linkwallet.db}"

mkdir -p "$(dirname "${DB_PATH}")"

cd /config
exec /app/linkwallet -db-path "${DB_PATH}"
```

- Idempotent: the app creates the bolt DB and `.bleve` index when missing and reuses them afterwards; nothing is seeded by the script.
- Writes only under `dirname DB_PATH` (default `/config`); nothing in `/app`; no caches needed.
- Listens on all interfaces through gin.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /
filePaths:
- /app/linkwallet
- /usr/share/licenses/linkwallet/LICENSE
```

The root path serves the search page (`r.GET("/")` in `web/web.go`). `timeoutSeconds` is left at the default like `apps/adguardhome-sync`. Tests run with no env vars, and the defaults in `start.sh` cover everything.

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: only the `-db-path` file and `<path>.bleve`. Remapped to `/config` (the chart used `/data`).
- Draft expectations match: non-root (568), read-only rootfs, not privileged. The one difference is the persistence path, `/data` upstream versus `/config` here. Operators with an existing `/data` PVC either mount it at `/config` or set `DB_PATH=/data/linkwallet.db` and mount `/data`; in the second case `/data` must be added to the chart. `/data` is not declared as a volume in `settings.yaml` because the default path does not use it.
- gin and the Go runtime need no `/tmp` writes at startup; `/tmp` is available if scraping needs it (UNVERIFIED).

## 10. Risks, caveats and open questions

- Upstream is archived on GitHub (moved to code.ppl.town) and at v0.1.1 since 2025-05. Renovate on the GitHub repo will never see a newer release; tracking the Forgejo host would need a different datasource (UNVERIFIED which one works).
- The draft's `8080`/web UI guess is confirmed. Draft claim of "login setup" is not confirmed: no auth was found (UNVERIFIED). If there is none, the app should only be exposed on an internal network or behind an authenticating proxy.
- Behind a reverse proxy the `BaseURL` setting in the web UI must be set or the bookmarklet breaks (README).
- The app queues every bookmark for re-scraping when the Bleve index is newly created, and calls GitHub for a version check every 6 hours; both need outbound network.
- Blockers: none. Static binaries exist for amd64 and arm64.

## 11. Build and test steps

```sh
cd apps/linkwallet
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create linkwallet-probe-config
docker run --rm -d --name linkwallet-probe --read-only --tmpfs /tmp \
  -v linkwallet-probe-config:/config linkwallet:0.1.1
docker logs -f linkwallet-probe   # expect "linkwallet version ... starting"; no fatal; container keeps running
curl -fsS http://<container-ip>:8080/ | head   # check it is reachable from outside the container
docker rm -f linkwallet-probe; docker volume rm linkwallet-probe-config
forgetool containers test --image linkwallet:0.1.1 --config ./apps/linkwallet/container-test.yaml
```

With `GIN_MODE=release` gin prints no "listening" line, so readiness is the `starting` line plus the open port. Restart once with the same volume to check the existing DB opens.

## 12. PR checklist

- Branch `feat/add-linkwallet` from `main`; commit and PR title `feat(linkwallet): add new container`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; check only the boxes that apply; `🤖 This PR is AI generated.` goes in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign; the `license/cla` check shows status).
- Mention in the PR: archived upstream, `/config` instead of `/data`, checksum-verified download.
- Untested so far: the image has not been built or run; arm64 binary and build not checked; the lack of authentication, outbound scraping and the `PORT` override have not been exercised.
