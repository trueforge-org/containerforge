# radarrsync — implementation plan
> Source: ./draft.md · Target: apps/radarrsync/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Which upstream | The chart image `dmanius/radarrsync-docker` is built from the fork https://github.com/dairefinn/RadarrSync (its README says so), not from the draft's `Sperryfreak01/RadarrSync`. The fork reads **environment variables**; the original reads a `Config.txt` file. |
| Version | The fork has no tags and no releases. Last commit `7546e59b7c6ca50f42460e919ebd86eb254a2c57` (2021-01-28); script `VER = '1.0.1'`. Original `Sperryfreak01/RadarrSync` has tags `v1.2.1`, `v1.2`, `v1.0` (the draft's `v1.0` link is a tag with no release). Recommended: the fork, pinned by commit (matches the chart's env contract). |
| Renovate | UNVERIFIED how well it works for a commit pin: `// renovate: datasource=git-refs depName=https://github.com/dairefinn/RadarrSync` with `versioning=loose` and a branch `master`. The repo is stale, so in practice nothing will update. Acceptable; say so in the PR. |
| License | None found: the GitHub API reports no license for either repo, and `Sperryfreak01` has no `LICENSE` file at `v1.2.1`. UNVERIFIED legal status. Put `LICENSE` = `NOASSERTION` in bake and flag it in the PR. There is nothing to copy into `/usr/share/licenses/`. |
| Source | https://github.com/dairefinn/RadarrSync (and original https://github.com/Sperryfreak01/RadarrSync) |
| Download | `https://github.com/dairefinn/RadarrSync/archive/7546e59b7c6ca50f42460e919ebd86eb254a2c57.tar.gz`, sha256 `c156d253d0b4b89d5a60ae42f1b094f1f2a101835c0557f44502001f32127d97` (computed by me; GitHub does not publish checksums for archives). No per-arch artifact: pure Python. |
| Upstream Dockerfile reviewed | Fork `Dockerfile`: `python:3-alpine`, `COPY RadarrSync.py requirements.txt startup.sh /`, `pip install -r requirements.txt`, `ENTRYPOINT ["sh","/startup.sh"]`. `startup.sh`: `while true; do python /RadarrSync.py; sleep 15m; done`. |
| Python deps | `requirements.txt` in the fork: `requests==2.20.0` (the original also lists `configparser==3.5.0`). |
| Env vars (fork `RadarrSync.py`) | `RADARR_URL`, `RADARR_KEY`, `RADARR4K_URL`, `RADARR4K_KEY`, `PROFILE_ID`. All are read with `os.environ[...]` (a missing one raises KeyError). |
| Ports | None. |
| Writes | `logging.FileHandler("./Output.txt")` in the **current directory**. |
| API | The script calls `/api/movie?apikey=...` (the Radarr v0.2 API). See the blocker in section 10. |

## 2. Target layout

```
apps/radarrsync/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` (no config file with the fork), no `health/`, no `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Python script with one pip dependency (`apps/feed2toot` and `apps/bazarr` do the same). The base provides `/app/venv`. Load the python-runtime rules: `/app/venv` stays read-only at runtime, caches go to `/tmp`.

## 4. Dockerfile

1. `FROM` as above, `ARG VERSION` (the commit sha), `USER root`.
2. `ENV PYTHONUNBUFFERED=1 PYTHONIOENCODING=utf-8` (as in `feed2toot`).
3. One `RUN`:
   - `mkdir -p /app/radarrsync`
   - `curl -fsSL -o /tmp/radarrsync.tar.gz "https://github.com/dairefinn/RadarrSync/archive/${VERSION}.tar.gz"`
   - `echo "c156d2...7d97  /tmp/radarrsync.tar.gz" | sha256sum -c -` (pin the value as `ARG SHA256`, default equal to the bake variable)
   - `tar xzf ... -C /app/radarrsync --strip-components=1`
   - install deps into the base venv: `/app/venv/bin/pip install --no-cache-dir -r /app/radarrsync/requirements.txt`. Decision to confirm at build time: `requests==2.20.0` (2018) may fail on Python 3.15 or pull vulnerable urllib3/chardet; if it does, relax it with `sed -i 's/==/>=/' /app/radarrsync/requirements.txt` before install (the script only uses `requests.Session().get/post`).
   - `chown -R apps:apps /app && chmod -R 755 /app`, `rm -rf /tmp/*`.
4. No apt packages (none needed; do not re-install what the base has).
5. `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`, `WORKDIR /config`. No `EXPOSE` (no port).
6. No license file to copy (upstream has none).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "radarrsync" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/dairefinn/RadarrSync versioning=loose
  default = "7546e59b7c6ca50f42460e919ebd86eb254a2c57"
}
variable "LICENSE" { default = "NOASSERTION" }
variable "SOURCE"  { default = "https://github.com/dairefinn/RadarrSync" }
```
Tag `${APP}:${VERSION}` with a 40-character sha is ugly; if reviewers prefer, use `VERSION = "1.0.1"` (the script's own `VER`) plus a separate `COMMIT` variable passed as an arg. Standard targets: `docker-metadata-action`, `image` (args VERSION, OCI labels), `image-local`, `image-all` (amd64 + arm64), `group "default"`. Check with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/dairefinn/RadarrSync"
ports: []
env:
  - name: RADARR_URL
    default: ""
    required: true
  - name: RADARR_KEY
    default: ""
    required: true
  - name: RADARR4K_URL
    default: ""
    required: true
  - name: RADARR4K_KEY
    default: ""
    required: true
  - name: PROFILE_ID
    default: ""
    required: true
  - name: DELAY
    default: "900"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
`required: true` with an empty default violates "required vars need a non-empty default or `start.sh` handling". `start.sh` handles it by waiting and logging (below). `DELAY` is read only by our `start.sh` (seconds; the fork hard-codes 15 minutes). The two Radarr instances are external, not ContainerForge dependencies (`apps/radarr` exists but is not required here).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -uo pipefail

DELAY="${DELAY:-900}"
cd /config                      # the script writes ./Output.txt here

missing=()
for v in RADARR_URL RADARR_KEY RADARR4K_URL RADARR4K_KEY PROFILE_ID; do
  [[ -n "${!v:-}" ]] || missing+=("$v")
done
if (( ${#missing[@]} )); then
  echo "radarrsync: waiting, missing required env: ${missing[*]}"
  exec sleep infinity
fi

# loop in the foreground; signals reach bash, trap them to exit cleanly
trap 'exit 0' TERM INT
while true; do
  /app/venv/bin/python /app/radarrsync/RadarrSync.py || echo "radarrsync: run failed (exit $?)"
  sleep "$DELAY" & wait $!
done
```
Keeps the container alive without env (needed because the test runs without any), idempotent, no writes to `/app`. Secrets are read by Python from the environment, so they never appear on the command line. There is no listening port.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /app/radarrsync/RadarrSync.py
runners:
- entrypoint: test -x /start.sh
```
`settings.yaml` has no ports, so no tcp/http probe is required. This mirrors `apps/feed2toot` (`runners` with `test -x /start.sh`). The required-env path (a real sync against two Radarr servers) cannot run in the test; check it by hand (section 11). Add `/app/venv/bin/python -c 'import requests'` as a second runner only if the forgetool schema accepts a command there (the sibling pattern uses `entrypoint`).

## 9. Rootless and read-only-rootfs adaptations

- Upstream write path: `./Output.txt` (cwd). Remapped by `cd /config` in `start.sh` (a persistent log, small). If the log is not wanted on disk, `cd /tmp` instead; the file is also mirrored to stdout, so `/tmp` is a valid choice. Plan: `/config` as the draft expects.
- Python caches/bytecode: `PYTHONDONTWRITEBYTECODE=1` is already set by the base; pip cache off at build.
- Chart runs UID/GID 0, `readOnlyRootFilesystem: false`, no persistence. The plan runs UID 568, read-only root, a `/config` volume (optional but recommended for the log).
- Not privileged.

## 10. Risks, caveats and open questions

- **Likely functional blocker:** the script uses `/api/movie`, the Radarr v0.2 API. Current Radarr (`apps/radarr` is 7.x) serves `/api/v3`. The container will start but each sync will log an error (HTTP 404 or similar, then `sys.exit(0)`). UNVERIFIED against a live Radarr. Options: ship it as is (TrueCharts parity), or patch the URLs to `/api/v3` (the payload fields would also need checking: `profileId` was removed in v3). Ask the maintainers before porting.
- No license on the upstream repo; redistribution rights are unclear.
- Draft said the original needs a hand-made `Config.txt`; that applies to `Sperryfreak01`, not to the fork the chart actually uses. If the original is chosen instead, `start.sh` must write `Config.txt` from env into `/config` (not `/app`) before running, and the script reads it from the cwd.
- Build depends on GitHub and the pip index; `requests==2.20.0` may not install on Python 3.15 (see section 4).
- The fork is unmaintained (last commit 2021) and Renovate will not move it.

## 11. Build and test steps

```sh
cd apps/radarrsync
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create radarrsync-probe-config
docker run --rm -d --name radarrsync-probe --read-only --tmpfs /tmp \
  -v radarrsync-probe-config:/config radarrsync:<VERSION>
docker logs radarrsync-probe      # expect "waiting, missing required env: ..." and the container still running
docker rm -f radarrsync-probe
# second run with fake values to exercise the Python path
docker run --rm --read-only --tmpfs /tmp -v radarrsync-probe-config:/config \
  -e RADARR_URL=http://127.0.0.1:1 -e RADARR_KEY=x -e RADARR4K_URL=http://127.0.0.1:1 -e RADARR4K_KEY=x -e PROFILE_ID=1 \
  -e DELAY=5 radarrsync:<VERSION>     # expect a connection error from the script, then a retry after 5 s, no crash
docker volume rm radarrsync-probe-config
forgetool containers test --image radarrsync:<VERSION> --config ./apps/radarrsync/container-test.yaml
```
Readiness signal: the "waiting" line (no env) or the script's own log line with the loop continuing.

## 12. PR checklist

- Branch `feat/add-radarrsync`, commit and PR title `feat(radarrsync): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; tick only what applies; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State untested: the live sync against Radarr (API version mismatch), arm64, the Python 3.15 install of the pinned `requests`, anything not built locally. Mention the missing upstream license and the stale fork.
- Confirm `bake --print` passes; `VERSION` in bake equals the Dockerfile `ARG VERSION`; no `root/`.
