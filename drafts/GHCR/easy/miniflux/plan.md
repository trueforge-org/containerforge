# miniflux — implementation plan
> Source: ./draft.md · Target: apps/miniflux/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **2.3.5** (tag `2.3.5`, published 2026-11-02, not prerelease). Matches chart image `ghcr.io/miniflux/miniflux:2.3.5`. Source: `gh api repos/miniflux/v2/releases/latest`; chart: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/miniflux/values.yaml |
| Renovate | `datasource=github-releases depName=miniflux/v2 versioning=loose` (expected annotation). UNVERIFIED: no fetched page confirms the `versioning` value. |
| License | Apache-2.0 (GitHub API repo license SPDX `Apache-2.0`; `LICENSE` exists at tag 2.3.5). |
| Source URL | https://github.com/miniflux/v2 |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/miniflux/v2/main/packaging/docker/alpine/Dockerfile: build stage `FROM docker.io/library/golang:alpine3.23`, runtime `FROM docker.io/library/alpine:3.24`, `make miniflux`, binary at `/usr/bin/miniflux`, `CMD ["/usr/bin/miniflux"]`, no ENTRYPOINT, `USER 65534`, `EXPOSE 8080`, `ENV LISTEN_ADDR=0.0.0.0:8080`, no VOLUME. We do not copy that image; we use the release binary. |
| Per-arch download (confirmed asset names, release 2.3.5) | amd64: https://github.com/miniflux/v2/releases/download/2.3.5/miniflux-linux-amd64 · arm64: https://github.com/miniflux/v2/releases/download/2.3.5/miniflux-linux-arm64. Both are plain Linux binaries, not archives. |
| Checksum source | Per-asset `.sha256` files on the same release. `miniflux-linux-amd64.sha256` = `19cddcf53c9a052ee5c1855b4204b53719f89a51143f69f1a264388e98e08cfd`; `miniflux-linux-arm64.sha256` = `7b6e457d4122c6afc269b38f57ebae5aef19e87a61bb3a1e4ba0f7c8fcd708d7`. The GitHub API `digest` field for the same assets matches. |
| `copy-from` | Not used. The release binary is the artifact we fetch. |
| apt package | UNVERIFIED: the draft's `apt: miniflux` was not confirmed against the Ubuntu 26.04 archive. Not used; the release binary is version-pinned and checksum-verified. |
| Env vars (names used by the chart) | `DATABASE_URL` (secret, postgres URL), `RUN_MIGRATIONS=1`, `CREATE_ADMIN=1`, `ADMIN_USERNAME=admin`, `ADMIN_PASSWORD` (secret). Source: chart values above. `LISTEN_ADDR` default `0.0.0.0:8080` from the upstream Dockerfile. UNVERIFIED: upstream docs (https://miniflux.app/docs/) not fetched, so semantics beyond the chart's use are not confirmed. |
| Port | 8080 TCP (HTTP UI). Chart liveness: HTTP `/healthcheck` on 8080. |
| Data/config write paths | Upstream: none (no VOLUME; state lives in PostgreSQL). The chart mounts `/config`, but the app does not need it. |
| arm64 | Yes: release asset `miniflux-linux-arm64` exists. |
| Dependencies | PostgreSQL (hard). Chart enables the postgresql dependency with database and user `miniflux`. `apps/postgresql` exists in this repo. |

## 2. Target layout

- `apps/miniflux/Dockerfile`: required.
- `apps/miniflux/docker-bake.hcl`: required.
- `apps/miniflux/settings.yaml`: required.
- `apps/miniflux/container-test.yaml`: required.
- `apps/miniflux/start.sh`: required.

Not needed: `defaults/` (all config is env), `etc/`, `scripts/`, `health/`, `root/` (never used). `DOWNSTREAM_CHANGES.md` only if this app is a `FROM` base, which it is not.

## 3. Base image

- FROM for the single stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.
- Why: a prebuilt Linux binary runs on glibc Ubuntu, so no separate runtime image is needed (the draft says the same).
- Closest sibling: `apps/adguardhome-sync` (prebuilt binary fetched in the ubuntu image, `USER apps`, `exec` in start.sh).

## 4. Dockerfile

Single stage, no compilation:

1. `ARG VERSION` and `ARG TARGETARCH`; `USER root`.
2. `ENV HOME=/config LISTEN_ADDR=0.0.0.0:8080`.
3. Fetch the binary and its checksum, verify, install to `/app/miniflux/miniflux`:
   ```sh
   case "${TARGETARCH}" in amd64|arm64) ;; *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; esac
   curl -fL -o /tmp/miniflux "https://github.com/miniflux/v2/releases/download/${VERSION}/miniflux-linux-${TARGETARCH}"
   curl -fL -o /tmp/miniflux.sha256 "https://github.com/miniflux/v2/releases/download/${VERSION}/miniflux-linux-${TARGETARCH}.sha256"
   echo "$(cut -d' ' -f1 /tmp/miniflux.sha256)  /tmp/miniflux" | sha256sum -c -
   install -D -m 0755 /tmp/miniflux /app/miniflux/miniflux
   ```
   The `.sha256` file content is `<hash>  miniflux-linux-<arch>`; the hash is taken from it and checked against the downloaded file.
4. License: fetch the upstream `LICENSE` at tag `2.3.5` to `/usr/share/licenses/miniflux/LICENSE` (file exists at the tag, section 1).
5. `chown -R apps:apps /app/miniflux && chmod -R 755 /app/miniflux`; `rm -f /tmp/miniflux /tmp/miniflux.sha256`.
6. Tail (sibling pattern):
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8080
   VOLUME /config
   ```
7. No apt step: `curl` and `sha256sum` come from the base.

## 5. docker-bake.hcl

Copy the layout of `apps/adguardhome-sync/docker-bake.hcl`:

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "miniflux"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=miniflux/v2 versioning=loose
  default = "2.3.5"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/miniflux/v2"
}
```

Then the standard `group "default"`, `target "image"`, `target "image-local"` (`tags = ["${APP}:${VERSION}"]`), and `target "image-all"` for `linux/amd64` and `linux/arm64`. Validate with `docker buildx bake --print` before any build.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/miniflux/v2"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: LISTEN_ADDR
    default: "0.0.0.0:8080"
    required: false
  - name: DATABASE_URL
    default: ""
    required: true
  - name: RUN_MIGRATIONS
    default: "1"
    required: false
  - name: CREATE_ADMIN
    default: "0"
    required: false
  - name: ADMIN_USERNAME
    default: "admin"
    required: false
  - name: ADMIN_PASSWORD
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: postgresql
```

- `DATABASE_URL` is `required: true` with an empty default. `start.sh` fails with a clear message when it is empty (section 7). The schema rule says required env needs a non-empty default or start.sh handling; start.sh handling applies, and this should be confirmed against forgetool.
- `/config` is listed because HOME points there; the app keeps no local state (open question, section 10).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export HOME=/config

if [ -z "${DATABASE_URL:-}" ]; then
  echo "ERROR: DATABASE_URL is required (postgres URL, e.g. postgres://user:pass@postgresql:5432/miniflux?sslmode=disable)" >&2
  exit 1
fi

cd /app/miniflux
exec /app/miniflux/miniflux
```

- Idempotent: writes nothing to `/config`; no seeding needed.
- `DATABASE_URL` is read from the environment, never written to a file or logged.
- `exec` so miniflux is PID 1 and receives signals.
- Listens on `LISTEN_ADDR` (default `0.0.0.0:8080`), so it is reachable from other containers.
- No writes to `/app`; no caches needed.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /app/miniflux/miniflux
- /usr/share/licenses/miniflux/LICENSE
# narrowed: requires external postgresql; full functional test not feasible in single-container suite
```

- The test runs without `DATABASE_URL`, so miniflux is expected to exit. A `tcp`/`http` probe on 8080 would fail in that setup, and the protocol forbids faking it. The file checks above are the planned narrowed minimum.
- If the step 3 run with postgresql shows miniflux stays up, add `tcp: port 8080` and `http: /healthcheck`, which the protocol requires for each declared port. Whether the CI test can reach a DB is an open question (section 10).

## 9. Rootless and read-only-rootfs adaptations

| Upstream/chart behaviour | Our handling |
| --- | --- |
| `USER 65534` upstream; chart `runAsUser 568` | Image runs as `apps`. Chart securityContext is not reproduced. |
| No writable paths (state in PostgreSQL) | Works with `--read-only --tmpfs /tmp`. HOME is `/config` for env only; nothing is written there. |
| Chart `readOnlyRootFilesystem` default true | Target `yes`. |
| Chart `privileged` | Not set, not needed. |
| Chart `/config` persistence | Kept (`VOLUME /config`) per sibling pattern; no data is written. |

## 10. Risks, caveats and open questions

- **PostgreSQL is a hard dependency.** Miniflux needs a reachable database. This is the DB-dependent exception in the build-test protocol: a hard `dependencies:` entry, does not start without it, not feasible as a single-container functional test. UNVERIFIED: exact exit/log behaviour without a DB; confirm in step 3.
- **Admin creation.** The chart uses `CREATE_ADMIN=1` with `ADMIN_USERNAME`/`ADMIN_PASSWORD` and a chart secret defaulting to `changeme`. Our image must not ship a default password; defaults above are empty.
- **Env semantics** beyond the chart's use (e.g. whether `RUN_MIGRATIONS` runs before listen) are UNVERIFIED: miniflux.app/docs was not fetched.
- **`/config` need.** The app stores nothing locally. If forgetool does not need a volume for stateless apps, drop it from settings.yaml and the Dockerfile.
- **Draft's apt route** is replaced by the checksum-verified release binary.
- **Blockers:** none for building. Runtime needs a PostgreSQL instance.

## 11. Build and test steps

From `apps/miniflux/` (protocol commands, `<app>` = `miniflux`):

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Empty-config run against a throwaway PostgreSQL on the same network:
   ```sh
   docker network create miniflux-probe-net
   docker run -d --name pg-probe --network miniflux-probe-net -e POSTGRES_USER=miniflux -e POSTGRES_PASSWORD=probe -e POSTGRES_DB=miniflux <postgresql image>
   docker run --rm -d --name miniflux-probe --network miniflux-probe-net --read-only --tmpfs /tmp \
     -v miniflux-probe-config:/config \
     -e DATABASE_URL='postgres://miniflux:probe@pg-probe:5432/miniflux?sslmode=disable' \
     -e CREATE_ADMIN=1 -e ADMIN_USERNAME=admin -e ADMIN_PASSWORD=probe-pass-1 \
     miniflux:2.3.5
   docker logs -f miniflux-probe
   ```
   Expected readiness signal: miniflux logs its listen address, the process stays running, no fatal errors.
4. `forgetool containers test --image miniflux:2.3.5 --config ./container-test.yaml` (CI mechanism). If forgetool is unavailable, check the file paths and the readiness log by hand.
5. Cleanup: `docker rm -f miniflux-probe pg-probe; docker volume rm miniflux-probe-config; docker network rm miniflux-probe-net`.
6. arm64 build only if an arm64-specific failure appears.

## 12. PR checklist

- Branch: `feat/add-miniflux`.
- Commit: `feat(miniflux): add new container`. PR title matches.
- PR body: template at `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes; check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge; only the user can sign. The `license/cla` check shows status.
- Not tested (state in the PR until done): arm64 build and run, the full functional test with PostgreSQL, renovate `versioning` confirmation, upstream env semantics. Do not check "Built container locally" unless the build ran.
