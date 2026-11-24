# llalon-github-backup — implementation plan
> Source: ./draft.md · Target: apps/llalon-github-backup/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | No releases or tags on abusesa/github-backup (master, 15 commits). Draft tag `latest`. Pin a commit SHA. UNVERIFIED: current SHA. |
| Renovate | `datasource=git-refs depName=https://github.com/abusesa/github-backup versioning=loose` (branch master); `VERSION` is a chosen value such as `0.0.0` plus a `GITHUB_BACKUP_REF` ARG with the pinned SHA (open question). |
| License | MIT (verified on the repo page). `LICENSE`: `MIT`. |
| Source | https://github.com/abusesa/github-backup |
| Downloads | Tarball of a pinned commit: `https://github.com/abusesa/github-backup/archive/<SHA>.tar.gz`. Pure Python, architecture-independent. Files: `backup.py`, `requirements.txt`, `setup.cfg`, `config.json.example`. |
| Checksum | None published; pin SHA and verify the tarball sha256 recorded in the Dockerfile. |
| Upstream usage (README, verified) | `pip3 install -r requirements.txt`, then `python3 backup.py config.json`. Config JSON keys: `token`, `directory`, optional `owners` (list). No environment variables. Token needs `repo` (or `public_repo`) scope. |
| Draft image | `llalon/github-backup` on Docker Hub; page returned 404, so its env vars and entrypoint are UNVERIFIED. No Dockerfile found. The image wrapper is not reproduced; the plan builds the wrapper itself. |

## 2. Target layout
- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`
- No `defaults/` needed (config is generated). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image
`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. The script is Python, so the python base (with `/app/venv`) fits better than the draft's ubuntu guess. Python rules apply: `/app/venv` read-only at runtime, caches in `/tmp`. Closest sibling: `apps/bazarr`. UNVERIFIED: the script's Python 3.15 compatibility (read `requirements.txt` and `setup.cfg`).

## 4. Dockerfile
1. `ARG VERSION`, `ARG GITHUB_BACKUP_REF`; `USER root`.
2. apt: `git` (needed at runtime; the backup clones repos). Check the base first. `curl` and `jq` from the draft are not needed by the script; omit unless start.sh uses them.
3. Download the pinned tarball, verify sha256, extract to `/app/github-backup`.
4. `pip install -r /app/github-backup/requirements.txt` into `/app/venv` (as bazarr: `uv pip install`), with caches in `/tmp`; no pip cache left behind.
5. Licenses: copy repo LICENSE to `/usr/share/licenses/llalon-github-backup/`.
6. `ENV HOME=/config GIT_CONFIG_GLOBAL=/tmp/gitconfig`; `chown -R root:root /app && chmod -R 755 /app`.
7. `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`, `CMD ["/start.sh"]`. No `EXPOSE` (no ports).

## 5. docker-bake.hcl
APP `llalon-github-backup`; VERSION with the renovate comment above; GITHUB_BACKUP_REF default (pinned SHA, own renovate comment); LICENSE `MIT`; SOURCE `https://github.com/abusesa/github-backup`. `image` args VERSION and GITHUB_BACKUP_REF; targets `docker-metadata-action`, `image`, `image-local` (tag `${APP}:${VERSION}`), `image-all` (amd64+arm64), `group "default"`. `docker buildx bake --print`.

## 6. settings.yaml
- Header, `schema_version: 1`, `upstream_env_url: "https://github.com/abusesa/github-backup"`.
- ports: `[]` (no ports; settings lists none).
- env (ContainerForge-defined, consumed only by start.sh; the upstream script reads a JSON file): `GITHUB_TOKEN` (required: false, no default; backup idles without it), `GITHUB_TOKEN_FILE` (path to a secret file, optional), `GITHUB_OWNERS` (comma-separated, optional, maps to `owners`), `BACKUP_DIR` (default `/config/backups`), `BACKUP_INTERVAL_SECONDS` (default `0` = run once then idle), `TZ`.
- volumes: `/config` (required; backups and state). The draft chart's two mounts (`/home/docker/backups`, `/home/docker/github-backup/config/`) are merged into `/config/backups` and `/config`.
- dependencies: none.

## 7. start.sh
- `set -euo pipefail`; `mkdir -p "$BACKUP_DIR"`.
- If no token (env or file): log a clear "no token set, idling" message and `exec sleep infinity` so the container stays up (no crash loop; this also lets the test run without env).
- Else write `/tmp/github-backup.json` with `umask 077` (tmpfs, not `/config`, keeps the secret out of persistence; build JSON with `python3 -c 'import json,os...'` so special characters are safe; never put the token on a command line).
- Loop: `python3 /app/github-backup/backup.py /tmp/github-backup.json`; if `BACKUP_INTERVAL_SECONDS` > 0 sleep and repeat, else after one run `exec sleep infinity` (keeps pod Running; document this) — alternatively exit 0 for Job use (open question).
- Never write to `/app`; handle TERM with a trap.

## 8. container-test.yaml
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
filePaths:
- /app/github-backup/backup.py
- /app/github-backup/requirements.txt
runners:
- entrypoint: git --version
- entrypoint: /app/venv/bin/python -c "import sys; sys.path.insert(0,'/app/github-backup'); import backup"
```
Not applicable: tcp/http probes, since `settings.yaml` lists no ports. The test runs without env, so the token path is not exercised; verify it manually (section 11). The `import backup` runner depends on the script having no side effects at import: UNVERIFIED, replace with `--help` if it parses args.

## 9. Rootless and read-only-rootfs adaptations
- Upstream image runs as root and writes to `/home/docker/...`; ours is `USER apps`, `HOME=/config`.
- Write paths: `/config/backups` (persistent clones), `/tmp/github-backup.json` (generated config), `/tmp/gitconfig`, pip cache in `/tmp`. Git needs `safe.directory` handling only if ownership differs; set via `GIT_CONFIG_GLOBAL`.
- Draft security (root, writable root, extra persistence in two paths) reconciled to rootless, read-only rootfs, single `/config` volume.

## 10. Risks, caveats and open questions
- No tagged releases: behavior changes only when the pinned SHA changes, so Renovate git-refs bumps need review.
- The `llalon/github-backup` wrapper (scheduling, env names) is unverified, so ContainerForge env names differ from it; document the migration.
- Backups can grow large and hit GitHub API rate limits.
- Token handling: secret only in env or a mounted file, written to tmpfs.
- Run-once vs loop semantics and whether to exit after one run.
- Python 3.15 compatibility of the old script and its pinned requirements.

## 11. Build and test steps
```sh
cd apps/llalon-github-backup
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create llalon-github-backup-probe-config
docker run --rm -d --name llalon-github-backup-probe --read-only --tmpfs /tmp \
  -v llalon-github-backup-probe-config:/config llalon-github-backup:<VERSION>
docker logs -f llalon-github-backup-probe     # expect the "no token set, idling" line
forgetool containers test --image llalon-github-backup:<VERSION> --config ./apps/llalon-github-backup/container-test.yaml
# manual token path, with a throwaway read-only token passed through the shell environment:
docker run --rm --read-only --tmpfs /tmp -e GITHUB_TOKEN -e GITHUB_OWNERS=<owner> \
  -v llalon-github-backup-probe-config:/config llalon-github-backup:<VERSION>
docker rm -f llalon-github-backup-probe; docker volume rm llalon-github-backup-probe-config
```
Expected readiness: container stays running; log shows the idle message without a token, or backup progress and repos under `/config/backups` with a token.

## 12. PR checklist
- Branch `feat/add-llalon-github-backup`; commit `feat(llalon-github-backup): add new container`; target `main`; template filled; Notes include `🤖 This PR is AI generated.`
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested at planning time: build, Python 3.15 compatibility, token run, rate limits, arm64.
- Pre-completion: bake --print, version alignment, USER apps, empty /config; no DOWNSTREAM_CHANGES.md.
