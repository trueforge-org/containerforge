# plex-playlist-sync — implementation plan
> Source: ./draft.md · Target: apps/plex-playlist-sync/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `1.0.2` (tag `v1.0.2`, released 2022-07-12; matches draft). `main` has one later commit (2022-08-14). Repository is **archived**. |
| Renovate | `datasource=github-releases` · `depName=rnagabhyrava/plex-playlist-sync` · `versioning=semver` (tags have a `v` prefix) |
| License | `GPL-3.0` (GitHub API `spdx_id: GPL-3.0`, file `LICENSE.md`). Use SPDX `GPL-3.0-only`? UNVERIFIED whether "or later": the API gives the ambiguous `GPL-3.0`; check the header of `LICENSE.md` before writing `LICENSE` in bake. |
| Source | https://github.com/rnagabhyrava/plex-playlist-sync |
| Download | `https://github.com/rnagabhyrava/plex-playlist-sync/archive/refs/tags/v${VERSION}.tar.gz` (pure Python, arch independent) |
| Checksum | None published. HTTPS only. |
| Upstream Dockerfile reviewed | `python:3.10-alpine`, `ENV PYTHONUNBUFFERED 1`, `pip install -r requirements.txt`, `COPY . .`, `CMD python ./plex-playlist-sync/run.py` (source folder is `plex-playlist-sync/` inside the repo). |
| requirements.txt | `spotipy>=2.18.0`, `plexapi==4.11.2`, `deezer-python>=2.3.0` |
| Ports | None. Pure client; loops forever (`time.sleep(SECONDS_TO_WAIT)`). |
| Env vars read (`run.py`) | `PLEX_URL`, `PLEX_TOKEN`, `WRITE_MISSING_AS_CSV` (`"0"`), `APPEND_SERVICE_SUFFIX` (`"1"`), `ADD_PLAYLIST_POSTER` (`"1"`), `ADD_PLAYLIST_DESCRIPTION` (`"1"`), `APPEND_INSTEAD_OF_SYNC` (unset = false; `"1"` = true), `SECONDS_TO_WAIT` (`86400`; README example uses 84000), `SPOTIFY_CLIENT_ID`, `SPOTIFY_CLIENT_SECRET`, `SPOTIFY_USER_ID`, `DEEZER_USER_ID`, `DEEZER_PLAYLIST_ID` (space separated ids) |
| Data path | Hard-coded `/data` (default arg of `_write_csv`/`_delete_csv` in `utils/plex.py`, `mkdir(parents=True)`): only used when `WRITE_MISSING_AS_CSV=1`. |
| Failure mode | Missing `PLEX_URL`/`PLEX_TOKEN` logs `Missing Plex Authorization Variables` and exits the loop (container exits 0). A bad Plex connection logs `Plex Authorization error` and exits. |

## 2. Target layout

```
apps/plex-playlist-sync/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No other files. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Why: Python script with three pure-Python dependencies and no extra services. Closest siblings: `apps/jbops` (Plex scripts, import-based test, no port) and `apps/bazarr` (python base, deps in the system interpreter).

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`; `USER root`.
2. `ENV HOME=/config PYTHONUNBUFFERED=1` (base already sets it; harmless).
3. `RUN`:
   - `curl -fsSL -o /tmp/pps.tar.gz "https://github.com/rnagabhyrava/plex-playlist-sync/archive/refs/tags/v${VERSION}.tar.gz"`
   - `mkdir -p /app/plex-playlist-sync && tar xzf /tmp/pps.tar.gz -C /app/plex-playlist-sync --strip-components=1` (entry point becomes `/app/plex-playlist-sync/plex-playlist-sync/run.py`)
   - `pip install -r /app/plex-playlist-sync/requirements.txt`
   - `rmdir /data && ln -s /config/data /data` (upstream writes CSVs to the hard-coded `/data`. The ubuntu base already creates `/data` as a directory, so it must be removed first; a plain `ln -s` would only create `/data/data`. The target is created at runtime)
   - `mkdir -p /usr/share/licenses/plex-playlist-sync && cp /app/plex-playlist-sync/LICENSE.md /usr/share/licenses/plex-playlist-sync/`
   - `rm -rf /tmp/* && chown -R root:root /app/plex-playlist-sync && chmod -R a+rX,go-w /app/plex-playlist-sync`
4. `USER apps`; `COPY --chmod=0755 . /`.
5. `VOLUME /config`; `WORKDIR /config`. No `EXPOSE` (no port).

No apt packages. `plexapi==4.11.2` is an exact pin from 2022 (pure Python); UNVERIFIED on Python 3.15.

## 5. docker-bake.hcl

- `APP = "plex-playlist-sync"`
- `VERSION`: `// renovate: datasource=github-releases depName=rnagabhyrava/plex-playlist-sync versioning=semver` + `default = "1.0.2"` (renovate will find nothing newer, the repo is archived).
- `LICENSE = "GPL-3.0-only"` pending the check in section 1; `SOURCE = "https://github.com/rnagabhyrava/plex-playlist-sync"`
- Four standard targets and the default group as in `apps/adguardhome-sync/docker-bake.hcl`; validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/rnagabhyrava/plex-playlist-sync"
ports: []
env:
  - name: PLEX_URL   # needed to do anything useful
    default: ""
    required: false
  - name: PLEX_TOKEN
    default: ""
    required: false
  - name: WRITE_MISSING_AS_CSV
    default: "0"
    required: false
  - name: APPEND_SERVICE_SUFFIX
    default: "1"
    required: false
  - name: ADD_PLAYLIST_POSTER
    default: "1"
    required: false
  - name: ADD_PLAYLIST_DESCRIPTION
    default: "1"
    required: false
  - name: APPEND_INSTEAD_OF_SYNC
    default: "0"
    required: false
  - name: SECONDS_TO_WAIT
    default: "86400"
    required: false
  - name: SPOTIFY_CLIENT_ID
    default: ""
    required: false
  - name: SPOTIFY_CLIENT_SECRET
    default: ""
    required: false
  - name: SPOTIFY_USER_ID
    default: ""
    required: false
  - name: DEEZER_USER_ID
    default: ""
    required: false
  - name: DEEZER_PLAYLIST_ID   # space separated
    default: ""
    required: false
volumes:
  - path: /config
    required: true
```
`ports` stays empty (no listener; check how sibling no-port apps such as `jbops/settings.yaml` write it). `PLEX_URL`/`PLEX_TOKEN` are `required: false` because `start.sh` handles absence. `APPEND_INSTEAD_OF_SYNC` has no default in code (false) and is exported as `0` by `start.sh`. No `dependencies`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data              # CSV output (/data -> /config/data); only used with WRITE_MISSING_AS_CSV=1

if [[ -z "${PLEX_URL:-}" || -z "${PLEX_TOKEN:-}" ]]; then
  echo "plex-playlist-sync: PLEX_URL and PLEX_TOKEN are required. Not configured, waiting."
  exec sleep infinity
fi

export APPEND_INSTEAD_OF_SYNC="${APPEND_INSTEAD_OF_SYNC:-0}"
cd /config                         # writable cwd (spotipy may write `.cache`); `utils.*` resolves from the script's directory
exec /usr/local/bin/python /app/plex-playlist-sync/plex-playlist-sync/run.py
```
Reason for idling: upstream would exit immediately (exit 0) when unconfigured, so the container could not satisfy the empty-start protocol or be tested. Secrets stay in env (the app reads env only; they are not echoed). Writes only under `/config`.

## 8. container-test.yaml

The app has no port and cannot stay up without a reachable Plex server, so use the `apps/jbops` pattern:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# narrowed: requires an external Plex server; no port, so only the install is verified.
# forgetool splits cmd on whitespace (no shell quoting), so commands are space-free and
# the expected strings are built at runtime.
runners:
- entrypoint: /usr/local/bin/python
  cmd: "-c __import__('plexapi'),__import__('spotipy'),__import__('deezer');print('pps'+'-ok')"
  expectedOutput: pps-ok
- entrypoint: /usr/local/bin/python
  cmd: "-c print('script'+'-ok'*__import__('os').path.isfile('/app/plex-playlist-sync/plex-playlist-sync/run.py'))"
  expectedOutput: script-ok

mainRunner:
  enabled: false
```
Hard-dependency-DB narrowing does not apply (the dependency is Plex, not a ContainerForge DB), so this follows the jbops precedent instead. The unconfigured path (`sleep infinity`) is covered by the manual run in section 11.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/data/<playlist>.csv` (hard-coded) | `/data` symlink to `/config/data`, directory created by `start.sh` |
| `__pycache__` in `/app` | disabled by `PYTHONDONTWRITEBYTECODE` (base) |
| spotipy token cache (`.cache` file in cwd) | cwd is `/config`, so a cache file can be written (UNVERIFIED which spotipy version writes it for client credentials) |

Draft reconciliation: chart runs UID 0 and writable rootfs, not needed. Extra persistence `/data` becomes `/config/data` (symlink keeps `-v ...:/data` working). Not privileged.

## 10. Risks, caveats and open questions

- Draft caveat confirmed: needs Plex token and, for Spotify, client id/secret/user id; Deezer needs only a profile id or playlist ids.
- Draft note about the chart pulling `:latest` while the release is v1.0.2: upstream's image tag does not track releases; we pin `1.0.2`.
- Repo archived since the last commit in 2022; no updates expected. `plexapi==4.11.2` is old; newer Plex servers may behave differently (UNVERIFIED).
- Exact license variant (GPL-3.0-only vs or-later) needs a check of `LICENSE.md`/file headers; GPL-3.0 text is shipped to `/usr/share/licenses/plex-playlist-sync/`.
- The idle behavior (`sleep infinity` when unconfigured) hides a misconfiguration from restart policies; it is logged clearly. Alternative: exit 1 and accept that step 3 cannot show a running container.
- Python 3.15 compat of the pinned/legacy dependencies is UNVERIFIED; fallback is the 3.14 python base.
- No upstream checksum. amd64 and arm64 identical.

## 11. Build and test steps

```sh
cd apps/plex-playlist-sync
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create plex-playlist-sync-probe-config
docker run --rm -d --name plex-playlist-sync-probe --read-only --tmpfs /tmp \
  -v plex-playlist-sync-probe-config:/config plex-playlist-sync:1.0.2
docker logs plex-playlist-sync-probe     # expect "not configured, waiting", container still running
docker rm -f plex-playlist-sync-probe
# configured run (needs a reachable Plex): expect "Starting playlist sync", "Starting Spotify playlist sync ... skipping", "Starting Deezer playlist sync"
docker run --rm -d --name plex-playlist-sync-probe --read-only --tmpfs /tmp \
  -e PLEX_URL=http://<plex>:32400 -e PLEX_TOKEN=<token> -e DEEZER_PLAYLIST_ID=<id> -e WRITE_MISSING_AS_CSV=1 \
  -v plex-playlist-sync-probe-config:/config plex-playlist-sync:1.0.2
docker logs -f plex-playlist-sync-probe
docker rm -f plex-playlist-sync-probe; docker volume rm plex-playlist-sync-probe-config
forgetool containers test --image plex-playlist-sync:1.0.2 --config ./apps/plex-playlist-sync/container-test.yaml
```
Check that `/config/data/*.csv` appears on the configured run. Maximum 10 rounds; clean up each round.

## 12. PR checklist

- Branch `feat/add-plex-playlist-sync`; commit and PR title `feat(plex-playlist-sync): add new container`; base `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md` with sections and checkboxes; tick only what applies.
- `🤖 This PR is AI generated.` in the Notes section.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it; the `license/cla` check shows status.
- Untested to list honestly: any run against a real Plex or Spotify/Deezer account, the CSV path, arm64, Python 3.15 compatibility, spotipy cache writes. Do not tick "Built container locally" unless built.
- Pre-completion: bake `--print` OK, versions aligned, rootless + read-only rootfs, empty `/config` start verified, tests not weakened.
