# quickshare — implementation plan
> Source: ./draft.md · Target: apps/quickshare/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `0.11.4` (tag `v0.11.4`, released 2026-01-30). Draft links the same tag. The chart uses `hexxa/quickshare:latest`. |
| Renovate | `datasource=github-releases depName=ihexxa/quickshare` (tags have a `v` prefix; the Dockerfile adds it, as `raneto` and `adguardhome-sync` do) |
| License | `LGPL-3.0-only`. GitHub reports `lgpl-3.0` and the repo `LICENSE` is the GNU LGPL v3 text. UNVERIFIED: whether source headers allow "or later". |
| Source | https://github.com/ihexxa/quickshare |
| amd64 | `https://github.com/ihexxa/quickshare/releases/download/v0.11.4/quickshare_linux_amd64.zip`, sha256 `36256309c20e5494bafc499f5b9288c41c3d12ac63c4ffced25aae6754ae4ce0` (downloaded and matched). |
| arm64 | `.../quickshare_linux_arm64.zip`, sha256 `b8434a01bba52feeed64d462a1d2ce110aa36aa7b020376ad0df37718230e7e7` (downloaded and matched). |
| Zip content | `dist/quickshare_linux_<arch>/quickshare` (one dynamic glibc binary, needs GLIBC_2.34 or lower, so it runs on ubuntu 26.04) and `dist/quickshare_linux_<arch>/lan.yml` (sample config). No LICENSE inside. The frontend is embedded: `src/server/init_handlers.go` serves it from an embedded FS unless `server.debug` is true; `fs.publicPath` must still be non-empty. |
| Checksum source | GitHub release asset digests (no checksum file). The digests above come from the GitHub API. |
| Upstream Dockerfile reviewed | `Dockerfile` on `main` (debian:stable-slim, UID/GID 8686, `/quickshare` dir, `CMD ["/quickshare/start", "-c", "/quickshare/demo.yml"]`) and `Dockerfile_default` (uses `configs/docker.yml`). The draft's pinned commit `f8216ab` was not fetched. The draft links `https://github.com/ihexxa/quickshare/blob/f8216ab/Dockerfile`. |
| Port | **8686**, not 3000 as the draft inferred (`server.port: 8686`, README `-p 8686:8686`, `host: "0.0.0.0"` in `configs/docker.yml`). |
| Env vars | README: `DEFAULTADMIN`, `DEFAULTADMINPWD` (initial admin; README example `qs`/`1234`). In `src/server/config.go` the fields tagged `cfg:"env"` are `DefaultAdmin`, `DefaultAdminPwd`, `Secrets.TokenSecret` and `Server.Port`, and `server.go` reads `ENV.PORT`. So `PORT` also overrides the port. `init_deps.go` reads `TOKENSECRET`; without it a random token secret is generated on each start (logins do not survive restarts). With no `DEFAULTADMIN` on first run (no DB yet), the app prompts for an admin name on stdin; with no `DEFAULTADMINPWD` it generates a password and prints it to the log. |
| DB path | `initDb` opens `path.Join(fs.root, db.dbPath)`, so `db.dbPath` is **relative to `fs.root`** (an absolute path is nested under the root). The file index `/fileindex.jsonl` also goes through the root-relative FS. |
| Config | `-c <file>` YAML. Keys seen in `configs/docker.yml`/`lan.yml`: `fs.root`, `fs.publicPath`, `db.dbPath` (sqlite), `server.host/port`, `users.*`. |

## 2. Target layout

```
apps/quickshare/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/quickshare.yml   # full config derived from lan.yml: paths moved to /config, host 0.0.0.0
```
`defaults/` is needed because the app requires a config file and `/config` starts empty (the allow-list in `include/.dockerignore` lets `defaults/` through). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

The release is a ready-made Go binary, so no Go build stage is needed (no Go compile happens in the image). Closest sibling: `apps/adguardhome-sync`.

## 4. Dockerfile

1. `FROM` as above; `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. No apt packages: `unzip`, `curl` and `ca-certificates` are already in the ubuntu base (`apps/ubuntu/Dockerfile`).
3. Arch mapping: `TARGETARCH` is already `amd64` or `arm64` and matches the asset names, so no mapping is needed. Pick the checksum by arch with a `case`, using the two digests above as ARGs `SHA256_AMD64` and `SHA256_ARM64` (they must be updated together with `VERSION`, since Renovate cannot bump them. Alternative: read the digest from the GitHub API at build time).
4. Download `https://github.com/ihexxa/quickshare/releases/download/v${VERSION#v}/quickshare_linux_${TARGETARCH}.zip` to `/tmp/qs.zip`, `echo "<sha>  /tmp/qs.zip" | sha256sum -c -`, `unzip -j /tmp/qs.zip 'dist/*/quickshare' -d /app`, `chmod 0755 /app/quickshare`, `chown -R apps:apps /app`.
5. License: `curl -fsSL https://raw.githubusercontent.com/ihexxa/quickshare/v${VERSION#v}/LICENSE -o /usr/share/licenses/quickshare/LICENSE` (create the dir first).
6. `rm -rf /tmp/*`.
7. `ENV HOME=/config` (as `adguardhome-sync`); no caches are expected.
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8686`, `VOLUME /config`.
9. The Dockerfile has no `CMD`; the base image runs `/start.sh`, as in the sibling apps.

## 5. docker-bake.hcl

Standard file as in `apps/adguardhome-sync` with:
```hcl
variable "APP" { default = "quickshare" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=ihexxa/quickshare
  default = "0.11.4"
}
variable "LICENSE" { default = "LGPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/ihexxa/quickshare" }
```
Add `SHA256_AMD64` and `SHA256_ARM64` variables (and pass them in `args`) if the checksums are pinned as args; the Dockerfile ARG defaults must equal them. Targets: `docker-metadata-action`, `image`, `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64 + arm64), `group "default"` = `image-local`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ihexxa/quickshare"
ports:
  - port: 8686
    protocol: tcp
    required: false
env:
  - name: DEFAULTADMIN
    default: "admin"
    required: false
  - name: DEFAULTADMINPWD
    default: ""
    required: false
  - name: PORT
    default: "8686"
    required: false
  - name: TOKENSECRET
    default: ""
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
The admin vars and `TOKENSECRET` are read by the app itself. `start.sh` defaults `DEFAULTADMIN` to `admin`, so the app never prompts on stdin; an empty password makes the app generate one and print it to the log. Both only apply when the database is first created.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/files

# seed config only when missing; never overwrite user edits
if [[ ! -f /config/quickshare.yml ]]; then
  cp /defaults/quickshare.yml /config/quickshare.yml
fi

# avoid the interactive admin-name prompt on first run
export DEFAULTADMIN="${DEFAULTADMIN:-admin}"

cd /config
exec /app/quickshare -c /config/quickshare.yml
```
`defaults/quickshare.yml` is `lan.yml` from the release with: `fs.root: /config/files`, `db.dbPath: quickshare.sqlite` (relative to `fs.root`, so the file is `/config/files/quickshare.sqlite`), `server.host: "0.0.0.0"`, `server.port: 8686`, `fs.publicPath` kept as shipped (`static/public`) because the frontend seems embedded, `secrets.tokenSecret: ""`, `users.defaultAdmin/defaultAdminPwd: ""` (the env vars supply them). Run from `/config` so any relative path resolves to the writable volume, never to `/app`. Port and admin are not written into the file by the script; the app reads `PORT`/`DEFAULTADMIN*` from the environment itself, so special characters in passwords never go through a shell or file.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
http:
- port: '8686'
  path: /
filePaths:
- /app/quickshare
- /usr/share/licenses/quickshare/LICENSE
```
Runs with no env vars. `/` should serve the embedded UI (UNVERIFIED status code; if it is not 200, fall back to `tcp` and record why). The admin-creation path (`DEFAULTADMIN`) is not covered, so test it by hand.

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: the files root (`fs.root`), the sqlite db (`db.dbPath`), the file index (`fileindex.jsonl` under the root, from `config.go`), and possibly temp upload data. All remap to `/config` via the seeded config. Nothing to `/app`. No cache env needed.
- Chart runs UID/GID 0 and `readOnlyRootFilesystem: false`; the plan uses UID 568 (`apps`), read-only root, `/tmp` tmpfs. Upstream's own image uses UID 8686; we do not need that.
- Persistence mismatch: the chart mounts `/quickshare/root`; here data and the database live in `/config/files` (`/config/files/quickshare.sqlite`). Migration note for the chart: copy the old root contents into `/config/files`.
- Not privileged.

## 10. Risks, caveats and open questions

- Draft caveat "port 3000" is wrong: the port is 8686. Draft caveat about data location is resolved by the seeded config.
- UNVERIFIED: whether the YAML config is merged over built-in defaults (a partial file may leave fields at zero). Using a full copy of `lan.yml` avoids the question.
- First run without `DEFAULTADMINPWD` prints a generated password to the log; users should change it at once or set the variable. Changing the admin variables later has no effect on an existing database.
- The upload speed limit (500 KB per cycle) and space limit (100 MB) in the sample config are demo values; set sensible limits in `defaults/quickshare.yml` after checking the doc (see `docs/doc.md`). Large uploads need a large `/config` volume.
- `cookieSecure: false` in the sample; behind HTTPS the user should flip it.
- Checksums pinned as build args need a manual bump with each Renovate version change.
- No blockers: Go binary is glibc, available for amd64 and arm64.

## 11. Build and test steps

```sh
cd apps/quickshare
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create quickshare-probe-config
docker run --rm -d --name quickshare-probe --read-only --tmpfs /tmp \
  -v quickshare-probe-config:/config -e DEFAULTADMIN=qs -e DEFAULTADMINPWD=changeme1 quickshare:0.11.4
docker logs -f quickshare-probe      # expect the server to be listening; container stays up
docker exec quickshare-probe bash -c 'exec 3<>/dev/tcp/127.0.0.1/8686 && echo open'
docker rm -f quickshare-probe; docker volume rm quickshare-probe-config
forgetool containers test --image quickshare:0.11.4 --config ./apps/quickshare/container-test.yaml
```
Repeat once without env vars and a fresh volume, and once with `--platform linux/arm64` if available. Check that a login and an upload work, and that `/config/files/quickshare.sqlite` appears.

## 12. PR checklist

- Branch `feat/add-quickshare`, commit and PR title `feat(quickshare): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; tick only what applies; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- List untested items honestly: arm64 run, first-run login behaviour, the `/` status code, config merge semantics, anything not executed locally. Do not tick "Built container locally" unless built.
- Confirm `bake --print` passes and `VERSION`/checksum args in bake and Dockerfile agree.
