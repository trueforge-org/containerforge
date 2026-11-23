# ntfy — implementation plan
> Source: ./draft.md · Target: apps/ntfy/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `2.38.1` (tag `v2.38.1`, Latest; security release; draft tag `v2.38.1`, same) |
| Renovate | `datasource=github-releases depName=binwiederhier/ntfy versioning=semver` |
| License | Dual: upstream image labels say "Apache-2.0, GPL-2.0". Use SPDX `Apache-2.0 OR GPL-2.0-only` (UNVERIFIED exact SPDX expression; confirm from the repo LICENSE files). |
| Source URL | https://github.com/binwiederhier/ntfy |
| Docs | https://docs.ntfy.sh/ |
| amd64 asset | https://github.com/binwiederhier/ntfy/releases/download/v2.38.1/ntfy_2.38.1_linux_amd64.tar.gz (the draft names the `.deb`; the tarball is also published, verified in the asset list) |
| arm64 asset | https://github.com/binwiederhier/ntfy/releases/download/v2.38.1/ntfy_2.38.1_linux_arm64.tar.gz |
| Checksum source | `checksums.txt` in the same release (verified present). Line format assumed `<sha256>  <file>` (UNVERIFIED). |
| Tarball layout | UNVERIFIED. Expected: one top folder with `ntfy`, `LICENSE`/`README`, `server/server.yml`, `client/`. Check with `tar tzf` and adjust. |
| Upstream Dockerfile reviewed | `v2.38.1/Dockerfile`: alpine, installs only tzdata, copies the prebuilt `ntfy` to `/usr/bin`, EXPOSE 80/tcp, `ENTRYPOINT ["ntfy"]`, no USER (root), no VOLUME. Command is `ntfy serve`. |
| Config | Config file normally `/etc/ntfy/server.yml`; every option can be set via `NTFY_<OPTION>` env (dashes to underscores), verified for `NTFY_BASE_URL`, `NTFY_AUTH_DEFAULT_ACCESS`, `NTFY_DATABASE_URL`. |
| Defaults (from server.yml) | `listen-http` `:80`; `cache-file` unset (in-memory, 12h); `auth-file` unset (auth off); `attachment-cache-dir` unset (attachments off; needs `base-url`); `behind-proxy` false; `web-root` `/`; `auth-default-access` `read-write`. |
| Package paths | Debian/RPM suggest `/var/cache/ntfy/cache.db` and `/var/lib/ntfy/user.db` (we remap to `/config`). |
| Ports | 80/tcp upstream; we use 8080 (see section 9). |

## 2. Target layout

```
apps/ntfy/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` (everything via env). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: single static-ish Go binary; ubuntu already has `curl`, `tar`, `tzdata`, `ca-certificates`, `sha256sum`, so no apt packages. Closest sibling: `apps/adguardhome-sync`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config`.
2. `RUN set -eux`:
   - `case "${TARGETARCH}" in amd64|arm64) ;; *) echo unsupported >&2; exit 1;; esac`
   - `base="https://github.com/binwiederhier/ntfy/releases/download/v${VERSION}"`; file `ntfy_${VERSION}_linux_${TARGETARCH}.tar.gz`.
   - `curl -fsSL -o /tmp/ntfy.tar.gz "$base/<file>"`, `curl -fsSL -o /tmp/checksums.txt "$base/checksums.txt"`, then `cd /tmp && grep " <file>\$" checksums.txt | sha256sum -c -`.
   - `mkdir -p /tmp/ntfy && tar xzf /tmp/ntfy.tar.gz --strip-components=1 -C /tmp/ntfy`; `install -m 0755 /tmp/ntfy/ntfy /app/ntfy`.
   - Licenses: `mkdir -p /usr/share/licenses/ntfy`; copy `LICENSE*` from the tarball if present, otherwise fetch `LICENSE` (Apache-2.0) and `LICENSE.GPLv2` from `https://raw.githubusercontent.com/binwiederhier/ntfy/v${VERSION}/` (file names UNVERIFIED). Required because only part of the archive is extracted.
   - `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/*`.
3. `USER apps`; `COPY --chmod=0755 . /`.
4. `EXPOSE 8080`; `VOLUME /config`.

## 5. docker-bake.hcl

`APP=ntfy`; `VERSION` with `// renovate: datasource=github-releases depName=binwiederhier/ntfy versioning=semver` default `"2.38.1"`; `LICENSE="Apache-2.0 OR GPL-2.0-only"`; `SOURCE="https://github.com/binwiederhier/ntfy"`. Standard four targets and `group "default"` copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/binwiederhier/ntfy"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: NTFY_LISTEN_HTTP
    default: ":8080"
    required: false
  - name: NTFY_BASE_URL
    default: ""
    required: false
  - name: NTFY_CACHE_FILE
    default: "/config/cache.db"
    required: false
  - name: NTFY_AUTH_FILE
    default: "/config/user.db"
    required: false
  - name: NTFY_ATTACHMENT_CACHE_DIR
    default: ""
    required: false
  - name: NTFY_BEHIND_PROXY
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

The `NTFY_*` names for base-url is verified; the rest follow the verified naming rule and the verified option names in server.yml, but confirm each in the `ntfy serve --help` output (it prints the env var next to each flag, UNVERIFIED) before finalizing, since a wrong name is silently ignored. Keep `NTFY_ATTACHMENT_CACHE_DIR` empty by default because upstream requires `base-url` to enable attachments. `dependencies`: none (draft: no hard or optional dependency containers).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export NTFY_LISTEN_HTTP="${NTFY_LISTEN_HTTP:-:8080}"
export NTFY_CACHE_FILE="${NTFY_CACHE_FILE:-/config/cache.db}"
export NTFY_AUTH_FILE="${NTFY_AUTH_FILE:-/config/user.db}"

mkdir -p "$(dirname "${NTFY_CACHE_FILE}")" "$(dirname "${NTFY_AUTH_FILE}")"
if [[ -n "${NTFY_ATTACHMENT_CACHE_DIR:-}" ]]; then
  mkdir -p "${NTFY_ATTACHMENT_CACHE_DIR}"
fi

# Optional user-provided config file; ntfy also reads env vars.
args=(serve)
if [[ -f /config/server.yml ]]; then
  args+=(--config /config/server.yml)
fi

exec /app/ntfy "${args[@]}"
```

Idempotent; no writes to `/app`; state only in `/config`; binds `:8080` (all interfaces). Does not seed `server.yml` (env is enough). Setting `auth-file` by default only creates the user DB; access stays open because `auth-default-access` remains `read-write` upstream (UNVERIFIED that creating an empty auth DB changes nothing; check first-run logs and an unauthenticated publish).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /
filePaths:
- /app/ntfy
- /usr/share/licenses/ntfy
```

Covers the only port. `/v1/health` is a documented ntfy health endpoint in current docs (UNVERIFIED in this session); once confirmed, add a second `http` probe with that path. No env needed for the default path. No database exception.

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes: message cache (SQLite), auth DB, attachment dir, web push / firebase files. All are remapped via env to `/config`. Nothing in `/app`. Caches/scratch go to `/tmp` by default.
- Draft security: non-root default 568 and read-only rootfs match. The draft's `/etc/ntfy` and `/var/cache/ntfy` PVCs are replaced by the single `/config` volume. Upstream default port 80 is privileged; we default `NTFY_LISTEN_HTTP=:8080`, so charts/Services must target 8080.
- Optional: users who mount `/etc/ntfy/server.yml` must instead place it at `/config/server.yml`.

## 10. Risks, caveats and open questions

- Draft caveats: set `base-url` to the public address for attachments/links; iOS push uses the upstream ntfy.sh relay unless `upstream-base-url` is configured (UNVERIFIED env name, do not add it).
- Behind a reverse proxy set `NTFY_BEHIND_PROXY=true` (otherwise all clients share one rate limit).
- Tarball layout, checksum format and license file names UNVERIFIED; first build round fixes them.
- Open: whether to set `auth-file` by default (current plan: yes, harmless) or leave auth fully off until the user opts in.
- No blockers: Go, linux amd64+arm64 tarballs exist.

## 11. Build and test steps

```sh
cd apps/ntfy
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name ntfy-probe --read-only --tmpfs /tmp \
  -v ntfy-probe-config:/config ntfy:2.38.1
docker logs -f ntfy-probe
# from outside: curl -fsS http://<container-ip>:8080/ ; publish test: curl -d hi http://<container-ip>:8080/test
docker exec ntfy-probe /app/ntfy serve --help | grep -i NTFY_   # confirm env names
forgetool containers test --image ntfy:2.38.1 --config ./apps/ntfy/container-test.yaml
docker rm -f ntfy-probe; docker volume rm ntfy-probe-config
```

Expected readiness signal: a log line like `Listening on :8080` (verified phrasing for the default is "Listening on :80", so expect the 8080 equivalent), process alive, no fatal errors. Restart on the same volume to confirm cache/auth DB reuse.

## 12. PR checklist

- Branch `feat/add-ntfy`, commit/PR title `feat(ntfy): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes; check only applicable boxes.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Confirm VERSION alignment, `bake --print`, `USER apps`, checksum verified, both license texts shipped.
- Untested at planning time: build, arm64, tarball layout, env var names beyond the verified ones, `/v1/health`, behavior with auth DB enabled.
