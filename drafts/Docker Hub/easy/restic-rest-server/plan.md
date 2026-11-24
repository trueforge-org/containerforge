# restic-rest-server — implementation plan
> Source: ./draft.md · Target: apps/restic-rest-server/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Latest stable | `v0.15.0` (GitHub release, published 2026-11-23, the day of verification). The draft says `0.14.0`; use 0.15.0 unless a maintainer prefers a soak period. Recheck the release notes before building. |
| Renovate | `datasource=github-releases depName=restic/rest-server versioning=semver` |
| License | BSD-2-Clause (README badge) |
| Source URL | https://github.com/restic/rest-server |
| amd64 | https://github.com/restic/rest-server/releases/download/v0.15.0/rest-server_0.15.0_linux_amd64.tar.gz (sha256 `822e3d7211077305ec358a8c6548ef46307ae53f71bc6a4a6da72ac53e35e007`) |
| arm64 | https://github.com/restic/rest-server/releases/download/v0.15.0/rest-server_0.15.0_linux_arm64.tar.gz (sha256 `1ed250ee1cc6229ca0d22085616292233d9714d4820bf5e4c37e1b29fc4de8ea`) |
| Checksums | `SHA256SUMS` (and `SHA256SUMS.asc`) release assets: https://github.com/restic/rest-server/releases/download/v0.15.0/SHA256SUMS |
| Draft link bug | The draft's amd64 link points to the `dragonfly_amd64` asset, which is the wrong OS. Use `linux_amd64`. |
| Port | 8000 (default `--listen :8000`) |
| Flags | `--path`, `--listen`, `--no-auth`, `--htpasswd-file`, `--private-repos`, `--append-only`, `--max-size`, `--prometheus`, `--prometheus-no-auth`, `--tls`, `--tls-cert`, `--tls-key`, `--tls-min-ver`, `--proxy-headers`, `--proxy-auth-username`, `--group-accessible-repos`, `--log`, `--debug`, `--no-verify-upload` |
| Docker env (upstream image) | `DATA_DIRECTORY` (default `/data`), `PASSWORD_FILE` (default `/data/.htpasswd`), `OPTIONS` (extra flags), `DISABLE_AUTHENTICATION` (any value turns on `--no-auth`) |
| Upstream entrypoint | `docker/entrypoint.sh`: adds `--no-auth` when `DISABLE_AUTHENTICATION` is set; otherwise creates `$PASSWORD_FILE` with `umask 027` if missing and warns when it is empty; then `exec rest-server --path "$DATA_DIRECTORY" --htpasswd-file "$PASSWORD_FILE" $OPTIONS`. |
| Upstream Dockerfile reviewed | https://github.com/restic/rest-server/blob/master/Dockerfile (alpine, `apache2-utils`, `tzdata`, helpers `create_user`/`delete_user`, VOLUME `/data`, EXPOSE 8000). The upstream README states it runs as arbitrary user with `--read-only` when only `/data` is writable. |
| Tarball contents | UNVERIFIED: expected `rest-server` binary plus `LICENSE`/`README`; list with `tar tzf` at build time and adjust the install lines. |

## 2. Target layout

```
apps/restic-rest-server/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  usr/local/bin/create_user    # htpasswd helper (kept under usr/ so the allow-list copies it)
  usr/local/bin/delete_user
```
- No `root/`, no `DOWNSTREAM_CHANGES.md` (not used as a FROM base).
- `usr/` is on the `.dockerignore` allow-list, so `COPY --chmod=0755 . /` places the helpers.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Static Go binary (upstream builds with `CGO_ENABLED=0`), so plain ubuntu works. Closest sibling: `apps/adguardhome-sync`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH` (`amd64`/`arm64` match the asset names directly).
2. `USER root`.
3. `ENV HOME=/config DATA_DIRECTORY=/config/data PASSWORD_FILE=/config/.htpasswd`.
4. apt (one layer, `--no-install-recommends`, clean lists): `apache2-utils` (provides `htpasswd` for `create_user`). Check first whether the ubuntu base already ships it. This is not the app itself, so it is not version-pinned; the app version comes from the tarball.
5. Download and verify:
```sh
set -eux
base="https://github.com/restic/rest-server/releases/download/v${VERSION#v}"
f="rest-server_${VERSION#v}_linux_${TARGETARCH}.tar.gz"
curl -fsSL -o "/tmp/${f}" "${base}/${f}"
curl -fsSL -o /tmp/SHA256SUMS "${base}/SHA256SUMS"
(cd /tmp && grep " ${f}\$" SHA256SUMS | sha256sum -c -)
mkdir -p /tmp/rs /usr/share/licenses/restic-rest-server
tar xzf "/tmp/${f}" -C /tmp/rs
install -m 0755 "$(find /tmp/rs -name rest-server -type f | head -1)" /app/rest-server
# copy LICENSE if present in the archive; otherwise fetch it from the tagged source
chown -R apps:apps /app && chmod -R 755 /app
rm -rf /tmp/rs /tmp/SHA256SUMS "/tmp/${f}"
```
   If the archive has no LICENSE, fetch `https://raw.githubusercontent.com/restic/rest-server/v${VERSION}/LICENSE` into `/usr/share/licenses/restic-rest-server/`.
6. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8000`, `VOLUME /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "restic-rest-server" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=restic/rest-server versioning=semver
  default = "0.15.0"
}
variable "LICENSE" { default = "BSD-2-Clause" }
variable "SOURCE"  { default = "https://github.com/restic/rest-server" }
```
Plus the standard `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64+arm64) targets and `group "default"` copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/restic/rest-server"
ports:
  - port: 8000
    protocol: tcp
    required: false
env:
  - name: DATA_DIRECTORY
    default: "/config/data"
    required: false
  - name: DISABLE_AUTHENTICATION
    default: ""
    required: false
  - name: OPTIONS
    default: ""
    required: false
  - name: PASSWORD_FILE
    default: "/config/.htpasswd"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```
No dependencies. The first four names are the upstream image's names; defaults differ from upstream on purpose (`/data` becomes `/config/...`, per the draft's `/config` expectation).

## 7. start.sh

```sh
#!/usr/bin/env bash
set -euo pipefail
DATA_DIRECTORY="${DATA_DIRECTORY:-/config/data}"
PASSWORD_FILE="${PASSWORD_FILE:-/config/.htpasswd}"
mkdir -p "${DATA_DIRECTORY}" "$(dirname "${PASSWORD_FILE}")"
args=(--path "${DATA_DIRECTORY}" --listen ":8000")
if [ -n "${DISABLE_AUTHENTICATION:-}" ]; then
  args+=(--no-auth)
else
  [ -f "${PASSWORD_FILE}" ] || (umask 027; : > "${PASSWORD_FILE}")
  [ -s "${PASSWORD_FILE}" ] || echo "WARNING: no users in ${PASSWORD_FILE}; run create_user, or set DISABLE_AUTHENTICATION" >&2
  args+=(--htpasswd-file "${PASSWORD_FILE}")
fi
# OPTIONS is a flag string, intentionally word-split like upstream
read -r -a extra <<< "${OPTIONS:-}"
exec /app/rest-server "${args[@]}" "${extra[@]}"
```
- Binds all interfaces (`:8000`).
- With an empty `.htpasswd` the server starts but rejects all logins (upstream behavior), so the no-env test still passes.
- `create_user <name> [password]` runs `htpasswd -B` on `$PASSWORD_FILE` (prefer reading the password from stdin with `htpasswd -B -i` so it stays out of the process list); `delete_user <name>` runs `htpasswd -D`. Write these two scripts from scratch; upstream's `docker/create_user` was not fetched. The `${extra[@]}` expansion with an empty array needs `set +u` handling or `${extra[@]+"${extra[@]}"}` in bash.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '8000'
filePaths:
- /app/rest-server
- /usr/local/bin/create_user
- /usr/local/bin/delete_user
```
Port 8000 is the only port. No HTTP probe: with auth enabled `GET /` returns 401/404 and the test runs without env, so a TCP probe is the honest check.

## 9. Rootless and read-only-rootfs adaptations

- Draft/chart: runAsUser 0, readOnlyRootFilesystem false, extra PVC `/data`. Target: user `apps`, read-only rootfs.
- Upstream writes: data dir (`--path`) and `.htpasswd` only. Remap to `/config/data` and `/config/.htpasswd`; nothing under `/app` or `/etc`.
- Persistence mismatch from the draft: upstream uses `/data`; this image uses `/config`. Document in the PR that existing `/data` volumes must be mounted at `/config/data` or `DATA_DIRECTORY=/data` set with a volume mounted there (needs write permission for `apps`).
- `htpasswd` for helper scripts writes only to `PASSWORD_FILE`.

## 10. Risks, caveats and open questions

- Draft caveats confirmed: auth needs an htpasswd file created by hand (`create_user`), or `DISABLE_AUTHENTICATION`; the restic repo password is client-side only.
- Version drift: v0.15.0 was published the same day as this plan; confirm it is not yanked. The draft's 0.14.0 is the fallback (asset names have the same shape).
- Only TLS-less HTTP is served by default; use `OPTIONS="--tls --tls-cert ... --tls-key ..."` with files in `/config`, or terminate TLS at an ingress.
- `--private-repos` and `--append-only` are passed via `OPTIONS`; nothing is enabled by default.
- UNVERIFIED: tarball file list; exact upstream `create_user` behavior.
- No blockers: static binary, amd64 and arm64.

## 11. Build and test steps

```sh
cd apps/restic-rest-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name restic-rest-server-probe --read-only --tmpfs /tmp \
  -v restic-rest-server-probe-config:/config restic-rest-server:0.15.0
docker logs -f restic-rest-server-probe   # expect the "no users" warning, then rest-server listening on :8000
docker exec restic-rest-server-probe create_user testuser    # then back up with restic from a second container
docker rm -f restic-rest-server-probe; docker volume rm restic-rest-server-probe-config
forgetool containers test --image restic-rest-server:0.15.0 --config ./apps/restic-rest-server/container-test.yaml
```
Also run once with `-e DISABLE_AUTHENTICATION=1` and `restic -r rest:http://host:8000/ init` (the auth path is not covered by the test).

## 12. PR checklist

- Branch `feat/add-restic-rest-server`, commit and PR title `feat(restic-rest-server): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; Notes contain `🤖 This PR is AI generated.`
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested until run: arm64, restic client round-trip, htpasswd helper scripts, `/data` migration path, and whether the tarball layout matches the install lines.
