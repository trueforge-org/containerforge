# gokapi — implementation plan
> Source: ./draft.md · Target: apps/gokapi/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `2.2.4` (tag `v2.2.4`, released 2026-03-10 to 2026-03-15; newest entry in the releases feed on 2026-11-23). Same as the draft. Docker Hub `f0rc3/gokapi` also has `v2.2.4`, `latest` (2026-03-10) and a `latest-dev`. |
| Renovate | `datasource=github-releases depName=Forceu/Gokapi` (same style as `apps/adguardhome-sync`, tags have a `v` prefix, `VERSION` is stored without it and the URL adds `v`). Semver is fine. |
| License | AGPL-3.0. `LICENSE.md` is the AGPL v3 text and the README says "licensed under the AGPL3". Whether it is "only" or "or later" is UNVERIFIED (no source header checked), so use `AGPL-3.0-only`. |
| Source | https://github.com/Forceu/Gokapi (docs: https://gokapi.readthedocs.io/en/latest/) |
| Per-arch URLs | `https://github.com/Forceu/Gokapi/releases/download/v2.2.4/gokapi-2.2.4_linux-amd64.zip` and `.../gokapi-2.2.4_linux-arm64.zip` (both exist). The zip holds one file, `gokapi` (53 MB, static Go binary, no license inside). There is also a separate `gokapi-cli-1.1.3_*` asset that is not needed. |
| Checksum source | No checksum file. GitHub shows a per-asset SHA-256 digest on the release page: amd64 `51dbf724c94f8afa0b40fb1ef63a1fe418e7996e7b9536e1f0a5da695b8e18ef` (both re-checked via the GitHub API on 2026-11-25; also confirmed by downloading and hashing it), arm64 `9f82cfb96fc48ac9bdfb94584dc6ba4648de1ac4fcd1276d2dd5a7e0f80398f7` (page value only, not downloaded). |
| Upstream Dockerfile | Reviewed (commit `9a4b289`): `golang:1.26.1-alpine` build with `CGO_ENABLED=0` and ldflags `-X ...environment.IsDocker=true`, final `alpine:3.19` with `tini`, `su-exec`, `curl`, `tzdata`, `/app/.isdocker`, `/app/run.sh` (deprecated `DOCKER_NONROOT` switch, otherwise `exec /app/gokapi "$@"`), `HEALTHCHECK curl --fail http://127.0.0.1:53842`. Alpine/musl is irrelevant: the release binary is static. Docker volumes upstream are `/app/data` and `/app/config`. |
| Port | `53842` (const `DefaultPort`, env `GOKAPI_PORT`). |
| Env vars (docs table plus `internal/environment/Environment.go` at v2.2.4) | `GOKAPI_PORT` (53842), `GOKAPI_CONFIG_DIR` (`config`), `GOKAPI_CONFIG_FILE` (`config.json`), `GOKAPI_DATA_DIR` (`data`), `GOKAPI_CHUNK_SIZE_MB` (45), `GOKAPI_MAX_FILESIZE` (102400), `GOKAPI_MAX_MEMORY_UPLOAD` (50), `GOKAPI_MAX_PARALLEL_UPLOADS` (3), `GOKAPI_LOG_STDOUT` (false), `GOKAPI_TRUSTED_PROXIES` (`127.0.0.1`, comma separated), `GOKAPI_USE_CLOUDFLARE` (false), `GOKAPI_MIN_FREE_SPACE` (400), `GOKAPI_MIN_LENGTH_PASSWORD` (8), `GOKAPI_LENGTH_ID` (15), `GOKAPI_DISABLE_CORS_CHECK`, `GOKAPI_DISABLE_API_MENU`, plus `GOKAPI_AWS_*`. Some are "persistent": they only take effect on the first start, when `config.json` is created. CLI flags exist too: `--config-dir`, `--data`, `--port`, `--config`, `--reconfigure`. |
| Files written | Config dir (`config.json`, optional `cloudconfig.yml`), data dir (uploads, SQLite database, logs). In Docker mode upstream sets `TMPDIR` to the data dir, because upload chunks are written to temp and then moved. |
| Docker detection | `IsDocker` is a build-time ldflag (`BuildVars.go`: `IsDockerInstance()` is `IsDocker != "false"`). The release binary is not built with it, so it behaves as a native install. In `Setup.go` (v2.2.4) this makes the setup form show a "bind to localhost" choice (`localhost_sel`), which only applies when not in Docker mode. `setup.tmpl` at `v2.2.4` defaults it to `No`. The initial setup web server listens on all interfaces and requires no authentication (`Setup.go`). |

## 2. Target layout

```
apps/gokapi/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`: gokapi creates its own config through the web setup (or from `GOKAPI_*` env on first start). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a
```

A static Go release binary needs no runtime. Do not install anything: `curl`, `unzip`, `tini`, `tzdata`, `ca-certificates` are in the ubuntu base (verified in `apps/ubuntu/Dockerfile`). Closest sibling: `apps/adguardhome-sync` (release archive into `/app`, `start.sh` that `exec`s the binary). The Go rules apply but there is no compile step (prebuilt binary), so no build stage.

## 4. Dockerfile

1. `FROM` above, `ARG VERSION`, `ARG TARGETARCH`, `ARG SHA256_AMD64=51dbf724...18ef`, `ARG SHA256_ARM64=9f82cfb9...98f7` (full values above). These cannot be renovated, so state in a comment that they must be updated with every `VERSION` bump.
2. `USER root` (only for the `/app` install and `chown`).
3. One `RUN`:
   - `case "${TARGETARCH}" in amd64) SHA="${SHA256_AMD64}";; arm64) SHA="${SHA256_ARM64}";; *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1;; esac`
   - `curl -fsSL -o /tmp/gokapi.zip "https://github.com/Forceu/Gokapi/releases/download/v${VERSION}/gokapi-${VERSION}_linux-${TARGETARCH}.zip"`
   - `echo "${SHA}  /tmp/gokapi.zip" | sha256sum -c -`
   - `unzip -q /tmp/gokapi.zip gokapi -d /app/`
   - `mkdir -p /usr/share/licenses/gokapi && curl -fsSL -o /usr/share/licenses/gokapi/LICENSE.md "https://raw.githubusercontent.com/Forceu/Gokapi/v${VERSION}/LICENSE.md"` (the zip has no license; the file path was verified at `v2.2.4`).
   - `chown -R apps:apps /app && chmod -R 755 /app`; `rm -f /tmp/gokapi.zip`.
4. `ENV HOME=/config GOKAPI_CONFIG_DIR=/config/config GOKAPI_DATA_DIR=/config/data` (the same names the app reads; they move upstream's `/app/config` and `/app/data` under the single `/config` volume).
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 53842`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "gokapi" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=Forceu/Gokapi
  default = "2.2.4"
}
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/Forceu/Gokapi" }
```

Standard blocks copied from `apps/adguardhome-sync/docker-bake.hcl`: `docker-metadata-action`, `group "default"` (`image-local`), `image` (args `VERSION`, OCI source and licenses labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Forceu/Gokapi"
ports:
  - port: 53842
    protocol: tcp
    required: true
env:
  - name: GOKAPI_PORT
    default: "53842"
    required: false
  - name: GOKAPI_CONFIG_DIR
    default: "/config/config"
    required: false
  - name: GOKAPI_DATA_DIR
    default: "/config/data"
    required: false
  - name: GOKAPI_LOG_STDOUT
    default: "true"
    required: false
  - name: GOKAPI_MAX_FILESIZE
    default: "102400"
    required: false
  - name: GOKAPI_CHUNK_SIZE_MB
    default: "45"
    required: false
  - name: GOKAPI_MAX_MEMORY_UPLOAD
    default: "50"
    required: false
  - name: GOKAPI_MAX_PARALLEL_UPLOADS
    default: "3"
    required: false
  - name: GOKAPI_TRUSTED_PROXIES
    default: "127.0.0.1"
    required: false
  - name: GOKAPI_USE_CLOUDFLARE
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Only variables from the verified list. All defaults match upstream defaults except `GOKAPI_LOG_STDOUT` (upstream `false`; `start.sh` sets `true` so logs are visible) and the two directory paths (Dockerfile `ENV`). `GOKAPI_PORT` keeps the app's own default. `dependencies:` omitted (SQLite is the default database; Redis is optional upstream and out of scope).

## 7. start.sh

```bash
#!/usr/bin/env bash

# Persistent state lives under /config (config.json, SQLite database, uploads, logs)
mkdir -p "${GOKAPI_CONFIG_DIR:-/config/config}" "${GOKAPI_DATA_DIR:-/config/data}"

# Upstream sets TMPDIR to the data dir in Docker mode: upload chunks are moved into the data dir,
# which fails across filesystems (/tmp is a tmpfs here). Keep it on the data volume.
export TMPDIR="${TMPDIR:-${GOKAPI_DATA_DIR:-/config/data}}"
export GOKAPI_LOG_STDOUT="${GOKAPI_LOG_STDOUT:-true}"

cd /config
exec /app/gokapi
```

Rules applied: idempotent (`mkdir -p` only), empty `/config` works (gokapi starts its web setup at `http://<host>:53842/setup`), nothing written to `/app`, caches only in `/tmp`, except the deliberate `TMPDIR` on the data volume for the cross-filesystem reason above (UNVERIFIED that the native build needs it; verify in section 11 with a >50 MB upload). `exec` for signal handling. The server must listen on all interfaces: the setup form's "bind localhost" option (default `No`) must stay off (section 10); `start.sh` cannot force it. No secrets in files or args (admin password is set in the setup UI).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '53842'
filePaths:
- /app/gokapi
```

One TCP probe for the only declared port. No `http` probe: the response of `/` before the first setup is UNVERIFIED (it probably redirects to `/setup`); add `http` with the observed path and status after the section 11 run if it is stable. The test runs with no env vars; that path is exactly the first-run state. Timeout: omit, like `apps/adguardhome-sync` (a static Go binary starts in seconds); add `timeoutSeconds: 60` if CI is slow.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write or privilege | Remap |
| --- | --- |
| `/app/config` (config.json, cloudconfig.yml) | `GOKAPI_CONFIG_DIR=/config/config` |
| `/app/data` (uploads, database, logs) | `GOKAPI_DATA_DIR=/config/data` |
| Temp upload chunks (`TMPDIR`) | `/config/data` (see section 7) |
| `/app/.isdocker`, `su-exec`, `DOCKER_NONROOT` | Not used; we run as `apps` from the start. |
| `run.sh` wrapper | Replaced by `start.sh`. |

Chart expectations reconciled: non-root yes (`apps`), `readOnlyRootFilesystem: true` yes (everything mutable is on `/config` or `/tmp`), not privileged. The chart's two PVCs (`/app/config`, `/app/data`) collapse into one `/config` volume. Note for users: the setup page prints a warning when `/app/data` and `/app/config` are not mounted volumes, but only in Docker mode, which the release binary does not use.

## 10. Risks, caveats and open questions

- First start needs the web setup (admin user, storage); the container is reachable but not usable before that (draft caveat). Non-interactive setup via `GOKAPI_*` env plus `--deployment-password` exists upstream but is out of scope.
- Setup form "bind to localhost" (`localhost_sel`): defaults to `No`. If a user selects `Yes`, `config.json` stores `127.0.0.1:53842` and the app becomes unreachable from other containers; document it.
- The initial setup page is unauthenticated on all interfaces: whoever reaches it first configures the instance. Do not expose the port before setup is done.
- Checksums are pinned ARGs and are not renovated: a Renovate bump of `VERSION` without matching hashes fails the build. Either accept the manual step or fetch the digest from the GitHub release API at build time (rate limited without a token, so it was not chosen).
- The arm64 hash was read from the release page, not computed from a download.
- Uploaded files live in `/config/data`; without a persistent mount they are lost (draft caveat). Large files need disk under `/config`, not RAM (`/tmp` is a tmpfs).
- `AGPL-3.0-only` vs `-or-later` is UNVERIFIED.
- No musl, GPU, privileged or arm64 blocker.

## 11. Build and test steps

```sh
cd apps/gokapi
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name gokapi-probe --read-only --tmpfs /tmp \
  -v gokapi-probe-config:/config -p 53842:53842 gokapi:2.2.4
docker logs -f gokapi-probe
curl -si http://127.0.0.1:53842/ | head -5      # record the status for a possible http probe
docker run --rm --network container:gokapi-probe docker.io/curlimages/curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:53842/setup
docker rm -f gokapi-probe; docker volume rm gokapi-probe-config
forgetool containers test --image gokapi:2.2.4 --config ./apps/gokapi/container-test.yaml
```

Expected readiness: the container keeps running, logs show Gokapi starting with the setup message ("Please open http://.../setup", wording UNVERIFIED), port 53842 is open and no errors about unwritable paths. Also: complete the setup in a browser from another container's network, restart on the same volume (state must survive), and upload a file larger than 50 MB to prove the `TMPDIR` choice.

## 12. PR checklist

- [ ] Branch `feat/add-gokapi` from `main`; commit and PR title `feat(gokapi): add new container`.
- [ ] Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only applicable boxes.
- [ ] `🤖 This PR is AI generated.` in the Notes section.
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- [ ] `docker buildx bake --print` exits 0.
- [ ] Say honestly what was not tested: arm64 build and run, the setup wizard and uploads end to end, the `TMPDIR` behaviour, and `forgetool` if it is unavailable locally. Do not tick "Built container locally" unless it was.
