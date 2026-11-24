# picoshare — implementation plan
> Source: ./draft.md · Target: apps/picoshare/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `1.5.5` (tag `v1.5.5`, released 2026-11-16; matches the draft) |
| Renovate | `datasource=github-releases` · `depName=mtlynch/picoshare` · `versioning=semver` (tag has `v` prefix: Dockerfile builds URLs with `v${VERSION}`) |
| License | `AGPL-3.0-or-later` (LICENSE text: "GNU Affero General Public License ... version 3 ... or (at your option) any later version"; GitHub reports `NOASSERTION` because of the custom header) |
| Source | https://github.com/mtlynch/picoshare (**archived**, upstream says it moved to codefloe.com/mtlynch/picoshare) |
| amd64 | `https://github.com/mtlynch/picoshare/releases/download/v1.5.5/picoshare-v1.5.5-linux-amd64.tar.gz` (contains one file: `picoshare`) |
| arm64 | `https://github.com/mtlynch/picoshare/releases/download/v1.5.5/picoshare-v1.5.5-linux-arm64.tar.gz` (also `linux-armv7`) |
| Checksum | No checksum file published. GitHub asset digests (informational): amd64 `sha256:72ab7116e861c2daecae6dbeb9912cdfe33182fdace86b5b7780671971f07bb4` (re-computed locally, matches), arm64 `sha256:94559027867322dc67b130ceb4f9dea9a9ab8f9e41440e75c5eb8ba2bfe10260` |
| Litestream (optional replication) | `v0.3.13`, Apache-2.0. Pinned by upstream's Dockerfile. `https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-{amd64,arm64}.tar.gz`. No checksum file; sha256 computed locally: amd64 `eb75a3de5cab03875cdae9f5f539e6aedadd66607003d9b1e7a9077948818ba0`, arm64 `9585f5a508516bd66af2b2376bab4de256a5ef8e2b73ec760559e679628f2d59`. Latest litestream is v0.5.18 but 0.5 changed the config format; stay on 0.3.13 with upstream's `litestream.yml`. |
| Upstream Dockerfile reviewed | `Dockerfile` @ master: Go builder, litestream downloader, `alpine` final stage with `/app/picoshare`, `/app/litestream`, `/app/docker-entrypoint`, `/etc/litestream.yml`; `CMD ["-db", "/data/store.db"]`. |
| Port | `PORT` env, default `4001` (`cmd/picoshare/main.go`: `port == "" -> "4001"`, `ListenAndServe(":port")`, all interfaces). The draft's `8080` is wrong. |
| Env read by the binary | `PORT`, `PS_SHARED_SECRET` (1 to 100 characters), `PS_SHARED_SECRET_FILE` (wins over `PS_SHARED_SECRET`, trailing newline stripped), `PS_BEHIND_PROXY` (any non-empty value enables proxy IP headers). Flag `-db <path>` (default `data/store.db`). |
| Startup requirement | The binary exits with `PS_SHARED_SECRET or PS_SHARED_SECRET_FILE must be set` if neither is given. |
| Env read by upstream entrypoint | `LITESTREAM_BUCKET` (enables replication), `LITESTREAM_ENDPOINT`, `LITESTREAM_ACCESS_KEY_ID`, `LITESTREAM_SECRET_ACCESS_KEY`, `LITESTREAM_PATH` (default `db`), `LITESTREAM_RETENTION` (default `72h`). |
| Ready log line | `listening on http://<hostname>:<port>` |

## 2. Target layout

```
apps/picoshare/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  etc/litestream.yml     # verbatim copy of upstream litestream.yml, lands at /etc/litestream.yml via COPY . /
```
`etc/` is on the `include/.dockerignore` allow-list. No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: prebuilt static Go binary (no Go build stage needed, `copy-from` is not available anyway). Closest sibling: `apps/adguardhome-sync`. glibc ubuntu is fine for these static binaries.

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`, `ARG TARGETARCH`, `ARG LITESTREAM_VERSION=0.3.13`; `USER root`.
2. `ENV HOME=/config LITESTREAM_PATH=db LITESTREAM_RETENTION=72h`.
3. Single `RUN`:
   - `curl -fsSL -o /tmp/picoshare.tar.gz "https://github.com/mtlynch/picoshare/releases/download/v${VERSION}/picoshare-v${VERSION}-linux-${TARGETARCH}.tar.gz"`; `tar xzf /tmp/picoshare.tar.gz -C /app picoshare` (`TARGETARCH` is `amd64`/`arm64`, same as the asset names, so no mapping table needed).
   - Download litestream the same way; verify with `echo "<sha256>  /tmp/litestream.tar.gz" | sha256sum -c -` using a `case "$TARGETARCH"` that selects the amd64 or arm64 hash from section 1; `tar xzf ... -C /app litestream`.
   - Licenses: `mkdir -p /usr/share/licenses/picoshare` then `curl -fsSL https://raw.githubusercontent.com/mtlynch/picoshare/v${VERSION}/LICENSE -o /usr/share/licenses/picoshare/LICENSE` and the litestream `LICENSE` from `https://raw.githubusercontent.com/benbjohnson/litestream/v${LITESTREAM_VERSION}/LICENSE` into `/usr/share/licenses/picoshare/LICENSE.litestream`.
   - `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/*`.
4. `USER apps`; `COPY --chmod=0755 . /`.
5. `EXPOSE 4001`; `VOLUME /config`; `WORKDIR /config`.

No apt packages. Comment in the Dockerfile that litestream is intentionally held at 0.3.13 (0.5 config format differs) and that picoshare has no upstream checksum.

## 5. docker-bake.hcl

Based on `apps/adguardhome-sync/docker-bake.hcl`:
- `APP = "picoshare"`
- `VERSION`: `// renovate: datasource=github-releases depName=mtlynch/picoshare versioning=semver` + `default = "1.5.5"`
- `LICENSE = "AGPL-3.0-or-later"`
- `SOURCE = "https://github.com/mtlynch/picoshare"`
- `image` passes `args.VERSION`; keep the four standard targets and `group "default"`. `image-all` platforms `linux/amd64`, `linux/arm64`.
- Validate with `docker buildx bake --print`. Litestream version is a Dockerfile `ARG` default only (not renovated).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/mtlynch/picoshare"
ports:
  - port: 4001
    protocol: tcp
    required: false
env:
  - PORT                       default "4001"  required false
  - PS_SHARED_SECRET           default ""      required false   # if empty and no file: start.sh generates /config/shared_secret
  - PS_SHARED_SECRET_FILE      default ""      required false
  - PS_BEHIND_PROXY            default ""      required false
  - LITESTREAM_BUCKET          default ""      required false
  - LITESTREAM_ENDPOINT        default ""      required false
  - LITESTREAM_ACCESS_KEY_ID   default ""      required false
  - LITESTREAM_SECRET_ACCESS_KEY default ""    required false
  - LITESTREAM_PATH            default "db"    required false
  - LITESTREAM_RETENTION       default "72h"   required false
volumes:
  - path: /config
    required: true
```
Write the env list in the sibling block form (`- name:` / `default:` / `required:`). `required` is false for the secret because `start.sh` handles the missing case. No `dependencies`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

DB_PATH="/config/store.db"; export DB_PATH   # litestream.yml references ${DB_PATH}
mkdir -p /config

# The binary refuses to start without a passphrase. Generate one once and keep it in /config.
if [[ -z "${PS_SHARED_SECRET:-}" && -z "${PS_SHARED_SECRET_FILE:-}" ]]; then
  SECRET_FILE=/config/shared_secret
  if [[ ! -s "${SECRET_FILE}" ]]; then
    ( umask 077; tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32 >"${SECRET_FILE}" ) || true
    echo "PS_SHARED_SECRET not set: generated an admin passphrase in ${SECRET_FILE}"
  fi
  export PS_SHARED_SECRET_FILE="${SECRET_FILE}"
fi

if [[ -n "${LITESTREAM_BUCKET:-}" ]]; then
  [[ -f "${DB_PATH}" ]] || /app/litestream restore -if-replica-exists "${DB_PATH}"
  exec /app/litestream replicate -exec "/app/picoshare -db ${DB_PATH}"
fi
exec /app/picoshare -db "${DB_PATH}"
```
Secrets never go in the log or process list (file based). `PORT` and `PS_BEHIND_PROXY` are read directly by the binary. Idempotent: restore only when the DB is missing; the generated secret is created once.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '4001'
filePaths:
- /app/picoshare
- /app/litestream
- /usr/share/licenses/picoshare/LICENSE
```
The test runs without env vars, which works only because `start.sh` generates the secret. The Litestream branch (`LITESTREAM_BUCKET` set) is not reachable from the test, so it is covered by the `/app/litestream` file check and must be exercised by hand per the protocol. An `http` probe on `/` can be added after step 3 confirms the status code (an unauthenticated visit may redirect; UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/data/store.db` (DB, upload chunks are stored inside SQLite) | `/config/store.db` via `-db` |
| litestream sidecar metadata next to the DB | stays in `/config` (same dir as the DB) |
| generated passphrase | `/config/shared_secret`, mode 0600 |
| `/app` | binaries only, read-only at runtime |

Draft reconciliation: non-root and read-only rootfs match the chart (UID 568 vs our `apps`). Extra persistence is `/data` in the chart but `/config` here; users migrating must move `/data/store.db` into `/config`. Not privileged.

## 10. Risks, caveats and open questions

- Draft caveat confirmed: without a secret the upstream binary will not start. This plan generates one so the image works and tests with no env, but then the generated passphrase is only readable from `/config/shared_secret`. Alternative: fail fast and put the container test in a `mainRunner.env` block; decide with maintainers.
- Draft port `8080` is wrong; real default is `4001`.
- Upstream repo is archived and has moved (codefloe.com). The GitHub release v1.5.5 exists today (2026-11-16), but later releases and Renovate's `github-releases` tracking may stop. UNVERIFIED: whether the new home publishes GitHub-compatible releases.
- Litestream replication needs S3-compatible credentials; only one container may use a replica path. Litestream is held at 0.3.13, and a `renovate.json` rule is not required because the version is not annotated.
- No upstream checksum for the picoshare tarball (HTTPS only); do not hard-code the GitHub digest because Renovate bumps would break the build.
- UNVERIFIED: whether picoshare needs write access outside `/config` and `/tmp` (none found in `main.go`).
- amd64 and arm64 tarballs exist; the binary is Go with no musl concern.

## 11. Build and test steps

```sh
cd apps/picoshare
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create picoshare-probe-config
docker run --rm -d --name picoshare-probe --read-only --tmpfs /tmp \
  -v picoshare-probe-config:/config picoshare:1.5.5
docker logs -f picoshare-probe     # expect "listening on http://...:4001" and the "generated an admin passphrase" line
docker rm -f picoshare-probe; docker volume rm picoshare-probe-config
forgetool containers test --image picoshare:1.5.5 --config ./apps/picoshare/container-test.yaml
```
Extra manual runs: (1) `-e PS_SHARED_SECRET=testpass` and log in on `:4001`; (2) restart with the same volume and confirm the passphrase file and DB are reused; (3) litestream path with a local MinIO (`LITESTREAM_*` set) to prove restore plus replicate start. Cleanup between rounds; maximum 10 rounds.

## 12. PR checklist

- Branch `feat/add-picoshare`; commit and PR title `feat(picoshare): add new container`; target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md` with sections and checkboxes kept; tick only what applies.
- `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA at https://cla-assistant.io/trueforge-org/containerforge; only the user can sign (`license/cla` check shows status).
- State what is untested: arm64 build and run, the litestream replicate/restore path, upload of large files on a read-only rootfs, whether `/` returns 200. Do not tick "Built container locally" unless it was built.
- Pre-completion: `docker buildx bake --print` OK, version aligned, rootless, read-only rootfs, empty `/config` start, no weakened tests.
