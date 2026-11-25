# radicale — implementation plan
> Source: ./draft.md · Target: apps/radicale/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `3.9.2` (GitHub `v3.9.2` released 2026-11-17; PyPI `radicale` 3.9.2, `requires-python >=3.9.0`). The draft's `3.9.2.0` is the tomsquest wrapper tag. |
| Renovate | `datasource=pypi depName=radicale` (same style as `apps/esphome`) |
| License | `GPL-3.0-or-later` (`pyproject.toml`: "GNU GPL v3"; file headers: "either version 3 ... or (at your option) any later version") |
| Source | https://github.com/Kozea/Radicale, docs https://radicale.org/v3.html |
| Install | `pip install radicale` (pure Python wheel, so no per-arch URL). Dependencies: `defusedxml`, `libpass>=1.9.3`, `vobject>=0.9.6`. Extra `bcrypt` gives bcrypt htpasswd support. |
| Checksum | PyPI hashes are checked by pip only with `--require-hashes`; plan relies on the exact `==3.9.2` pin. PyPI lists the wheel `radicale-3.9.2-py3-none-any.whl` with sha256 `88a28c460af1f1c09745fefe1fb91aaf1b631499240eaaef5796a347b4c965ba`. |
| Upstream Dockerfile reviewed | https://github.com/tomsquest/docker-radicale/blob/master/Dockerfile (tag 3.9.2.0 not fetched): `alpine:3`, venv at `/venv`, `pip install radicale==$VERSION passlib[bcrypt] argon2-cffi pytz ldap3`, config at `/config/config`, data `/data`, UID/GID 2999, `EXPOSE 5232`, `--config /config/config`. |
| Defaults (`radicale/config.py`, v3.9.2) | `server.hosts = localhost:5232` (**not reachable from outside the container**), `auth.type = denyall` (since 3.5.0), `auth.htpasswd_filename = /etc/radicale/users`, `auth.htpasswd_encryption = autodetect`, `storage.filesystem_folder` (user must set), `rights.type = owner_only`. |
| Env | Radicale reads `RADICALE_CONFIG` (path to the config file; DOCUMENTATION.md). All other settings are in the config file or CLI flags. There are no other env vars. |
| Port | 5232/tcp |

## 2. Target layout

```
apps/radicale/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/config      # seeded to /config/config when missing
```
`defaults/` is needed because the packaged default config binds to localhost and denies all logins. No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Pure Python app; closest sibling `apps/feed2toot` (pip install into `/app/venv`). Radicale supports Python up to 3.14 in its classifiers. UNVERIFIED on 3.15, so check the build. If a dependency breaks on 3.15, stay on the newest python base that works and add the comment used in `apps/changedetection` explaining why.

## 4. Dockerfile

1. `FROM` as above; `ARG VERSION`; `USER root`.
2. `ENV PYTHONUNBUFFERED=1 PYTHONIOENCODING=utf-8`. No apt packages (wheels cover amd64 and arm64; `bcrypt` ships manylinux wheels, UNVERIFIED for 3.15).
3. `RUN` (still root, for ownership):
   - `/app/venv/bin/pip install --no-cache-dir "radicale[bcrypt]==${VERSION}"` into the base venv (read-only at runtime, written only at build).
   - `mkdir -p /usr/share/licenses/radicale && curl -fsSL "https://raw.githubusercontent.com/Kozea/Radicale/v${VERSION}/COPYING.md" -o /usr/share/licenses/radicale/COPYING.md` (`COPYING.md` exists at the root of tag `v3.9.2`).
   - `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/* $HOME/.cache`.
4. `ENV HOME=/config RADICALE_CONFIG=/config/config`.
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 5232`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "radicale" }
variable "VERSION" {
  // renovate: datasource=pypi depName=radicale
  default = "3.9.2"
}
variable "LICENSE" { default = "GPL-3.0-or-later" }
variable "SOURCE"  { default = "https://github.com/Kozea/Radicale" }
```
Plus the standard `docker-metadata-action`, `image` (args.VERSION + OCI source/licenses labels), `image-local` (`type=docker`, `${APP}:${VERSION}`), `image-all` (amd64 + arm64), `group "default"`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Kozea/Radicale"
ports:
  - port: 5232
    protocol: tcp
    required: false
env:
  - name: RADICALE_CONFIG
    default: "/config/config"
    required: false
  - name: RADICALE_USER
    default: ""
    required: false
  - name: RADICALE_PASSWORD
    default: ""
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
`RADICALE_CONFIG` is read by Radicale itself. `RADICALE_USER` and `RADICALE_PASSWORD` are read only by `start.sh` (image-level feature to create or update one htpasswd user).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/collections

[[ -f /config/config ]] || cp /defaults/config /config/config

[[ -f /config/users ]] || install -m 600 /dev/null /config/users

# when both vars are set, (re)apply that user on every start; other entries are kept
if [[ -n "${RADICALE_USER:-}" && -n "${RADICALE_PASSWORD:-}" ]]; then
  case "$RADICALE_USER" in *:*|*$'\n'*) echo "RADICALE_USER must not contain ':' or newlines" >&2; exit 1;; esac
  /app/venv/bin/python - <<'PY'
import os
from passlib.hash import bcrypt
path, user = "/config/users", os.environ["RADICALE_USER"]
with open(path) as f:
    lines = [l for l in f.read().splitlines() if l.split(":", 1)[0] != user]
lines.append(f"{user}:{bcrypt.hash(os.environ['RADICALE_PASSWORD'])}")
tmp = path + ".new"
with open(os.open(tmp, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600), "w") as f:
    f.write("\n".join(lines) + "\n")
os.replace(tmp, path)
PY
elif [[ ! -s /config/users ]]; then
  echo "radicale: no users configured; set RADICALE_USER/RADICALE_PASSWORD or add bcrypt entries to /config/users" >&2
fi

exec /app/venv/bin/python -m radicale --config "${RADICALE_CONFIG:-/config/config}"
```
The password goes through the environment into Python, never onto a command line or into a shell expansion, so special characters are safe. `defaults/config`:
```ini
[server]
hosts = 0.0.0.0:5232

[auth]
type = htpasswd
htpasswd_filename = /config/users
htpasswd_encryption = autodetect

[storage]
filesystem_folder = /config/collections

[logging]
level = info
```
(IPv6 `[::]:5232` is left out on purpose: it can fail when the container has no IPv6.) The `passlib` import name comes from `libpass`; UNVERIFIED that `bcrypt.hash` output (`$2b$`) is accepted by `autodetect`; docs say autodetect supports bcrypt.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '5232'
filePaths:
- /app/venv/bin/radicale
- /usr/share/licenses/radicale/COPYING.md
```
TCP is used because every HTTP path may need auth or redirect (UNVERIFIED which path returns 200 without login; try `/.web/` and switch to `http` if it does). The test has no env, so the user-creation branch is not covered; run it by hand with `-e RADICALE_USER -e RADICALE_PASSWORD` and `curl -u`.

## 9. Rootless and read-only-rootfs adaptations

- Upstream write paths: the collections tree and its lock/cache (`filesystem_folder`, cache defaults to the same folder), the htpasswd file. All under `/config`. Nothing to `/app`; pip cache and bytecode stay off.
- Chart: UID/GID 2999, read-only root, caps SETUID/SETGID/KILL. The plan uses UID 568 (`apps`), no extra capabilities (nothing calls `su`), read-only root, `/tmp` tmpfs.
- Persistence mismatch: the chart uses `/data` for collections and config maps at `/config/config`, `/config/users`. Here everything is under `/config` (`/config/collections`, `/config/config`, `/config/users`). Chart migration: mount the old data at `/config/collections`.
- Not privileged.

## 10. Risks, caveats and open questions

- Draft caveats: the htpasswd users file must exist (handled with seeded file and optional env user, but a user with no password env cannot log in, by design); clients need a published port or reverse proxy.
- Without the seeded `[server] hosts` line the server only listens on localhost; this is the main trap.
- The env user is re-applied on every start, so a changed `RADICALE_PASSWORD` takes effect; removing the variables does not delete the user. Other users are managed by editing `/config/users`. UNVERIFIED: password length limits of `libpass` with the installed `bcrypt` (bcrypt only uses 72 bytes).
- UNVERIFIED: Python 3.15 compatibility of `vobject`, `libpass` and `bcrypt` wheels on arm64.
- No blockers (pure Python, glibc, both arches, no privilege).

## 11. Build and test steps

```sh
cd apps/radicale
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create radicale-probe-config
docker run --rm -d --name radicale-probe --read-only --tmpfs /tmp \
  -v radicale-probe-config:/config -e RADICALE_USER=alice -e RADICALE_PASSWORD='p@ss:w0rd' radicale:3.9.2
docker logs -f radicale-probe     # expect Radicale "Listening on '0.0.0.0:5232'" style line, container stays up
docker run --rm --network container:radicale-probe curlimages/curl -su 'alice:p@ss:w0rd' -X PROPFIND http://127.0.0.1:5232/alice/ -o /dev/null -w '%{http_code}\n'   # connect from outside the app process
docker rm -f radicale-probe; docker volume rm radicale-probe-config
forgetool containers test --image radicale:3.9.2 --config ./apps/radicale/container-test.yaml
```
Also start once with no env and a fresh volume (expect the "no users configured" line and a running container), and restart on the same volume to prove idempotence.

## 12. PR checklist

- Branch `feat/add-radicale`, commit and PR title `feat(radicale): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; tick only what applies; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State untested items: arm64, Python 3.15 wheels, authenticated CalDAV/CardDAV requests, the license file download step, anything not built locally.
- Confirm `bake --print` passes; `VERSION` equals the Dockerfile `ARG`; no `root/`.
