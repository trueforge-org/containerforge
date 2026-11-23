# namecheap-ddns — implementation plan
> Source: ./draft.md · Target: apps/namecheap-ddns/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | No releases or tags upstream. Pin the commit `421a554e5267e6405850f0fe302ff95600dc8539` (the draft's Dockerfile link; the `src` tree at HEAD resolved to commit 421a554, so it is current as of 2026-11-23). Draft tag was `latest`. |
| Renovate | `datasource=git-refs depName=https://github.com/EdwardChamberlain/namecheap_ddns currentValue=main` (same style as `apps/tvheadend`) |
| License | AGPL-3.0 (README/license shown as AGPL-3.0); SPDX `AGPL-3.0-only` (UNVERIFIED whether "or later") |
| Source URL | https://github.com/EdwardChamberlain/namecheap_ddns |
| Download | `https://github.com/EdwardChamberlain/namecheap_ddns/archive/<sha>.tar.gz` (GitHub source archive, no per-arch binary; pure Python so amd64+arm64 identical) |
| Checksum source | None published. Pinning a full commit SHA is the integrity anchor. |
| Layout | repo root: `src/` (`config.py`, `main.py`, `dockerfile`), `LICENSE`, `README.md`. |
| Upstream Dockerfile reviewed | `src/dockerfile`: `FROM python:3.11-slim`, `COPY src/ /app/`, `RUN pip install requests`, runs the main script with unbuffered Python. |
| Env vars (verified) | `APP_HOST`, `APP_DOMAIN`, `APP_PASSWORD` (required, `;`-separated lists of equal length), `APP_UPDATE_TIME` (seconds, default 60 per code; README says the IP is checked every 3 seconds, a discrepancy, trust the code and re-verify), `APP_LOG_LEVEL` (default `INFO`). |
| Behavior | Infinite loop; one HTTP GET per target to `dynamicdns.park-your-domain.com/update`; writes no files; exits if required vars missing or list lengths differ. |
| Python deps | `requests` only. Upstream version pin: none. |
| Ports | None. |

## 2. Target layout

```
apps/namecheap-ddns/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` (no config file). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Why: pure-Python script needing `requests`; the base ships `/app/venv` (read-only at runtime) plus `curl`, `tar`. Upstream uses Python 3.11; compatibility with 3.15 is UNVERIFIED (simple script, low risk, covered by the import test). Closest siblings: `apps/bazarr` (python base, start.sh launching `python`), `apps/changedetection` (pip into `/app/venv`). Python rules from `python-runtime.instructions.md` apply: use `/app/venv` read-only, no cache in `/config`.

## 4. Dockerfile

1. `ARG VERSION`; `USER root`; `ENV HOME=/config PYTHONUNBUFFERED=1`.
2. One `RUN set -eux`:
   - `mkdir -p /app/namecheap-ddns /usr/share/licenses/namecheap-ddns`
   - `curl -fsSL "https://github.com/EdwardChamberlain/namecheap_ddns/archive/${VERSION}.tar.gz" | tar xz --strip-components=1 -C /tmp/src` (create `/tmp/src` first), then `cp /tmp/src/src/main.py /tmp/src/src/config.py /app/namecheap-ddns/` (do not copy `src/dockerfile`) and `cp /tmp/src/LICENSE /usr/share/licenses/namecheap-ddns/`.
   - `/app/venv/bin/pip install --no-cache-dir "requests==${REQUESTS_VERSION}"` with `ARG REQUESTS_VERSION` and a `# renovate: datasource=pypi depName=requests` comment above it. Pick the current stable at implementation time (UNVERIFIED now). Keep the pin in the Dockerfile as an ARG default (sibling `changedetection` does the same with PLAYWRIGHT_VERSION).
   - `chown -R apps:apps /app/namecheap-ddns && chmod -R 755 /app/namecheap-ddns`; `rm -rf /tmp/src`.
3. `USER apps`; `COPY --chmod=0755 . /`; `WORKDIR /config`.
4. No `EXPOSE`. `VOLUME /config` (kept for contract consistency; the app writes no state).

## 5. docker-bake.hcl

`APP=namecheap-ddns`; `VERSION` default `"421a554e5267e6405850f0fe302ff95600dc8539"` preceded by `// renovate: datasource=git-refs depName=https://github.com/EdwardChamberlain/namecheap_ddns currentValue=main`; `LICENSE="AGPL-3.0-only"`; `SOURCE="https://github.com/EdwardChamberlain/namecheap_ddns"`. Standard four targets and default group per `apps/adguardhome-sync/docker-bake.hcl`. `image-local` tag becomes `namecheap-ddns:<sha>`; open question whether to expose a short form. Validate: `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/EdwardChamberlain/namecheap_ddns"
ports:
  []
env:
  - name: APP_HOST
    default: ""
    required: true
  - name: APP_DOMAIN
    default: ""
    required: true
  - name: APP_PASSWORD
    default: ""
    required: true
  - name: APP_UPDATE_TIME
    default: "60"
    required: false
  - name: APP_LOG_LEVEL
    default: "INFO"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: false
```

Rule check: `required: true` without a default is allowed only if `start.sh` handles it; it does (validation with a clear message, section 7). `dependencies`: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

for v in APP_HOST APP_DOMAIN APP_PASSWORD; do
  if [[ -z "${!v:-}" ]]; then
    echo "[namecheap-ddns] ${v} is required (use ';' to separate multiple hosts/domains/passwords)" >&2
    exit 1
  fi
done

export PYTHONDONTWRITEBYTECODE=1
cd /app/namecheap-ddns
exec /app/venv/bin/python -u /app/namecheap-ddns/main.py
```

Notes: only the app's own env (`APP_*`) is passed through; the password stays in the environment, never on a command line. Nothing is written to `/app` (bytecode off, `/app` read-only); no `/config` seeding needed. `exec` keeps signals correct. Do not log the password; upstream may print the request URL on failure (see risks).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# No port exists and the app exits without APP_* variables (the test cannot set env),
# so the main process is disabled and the install is verified instead.
filePaths:
- /app/namecheap-ddns/main.py
- /app/namecheap-ddns/config.py
- /start.sh
runners:
- entrypoint: /app/venv/bin/python
  cmd: "-c __import__('requests');print('requests'+'-ok')"
  expectedOutput: requests-ok

mainRunner:
  enabled: false
```

Pattern from `apps/limnoria/container-test.yaml` (space-free cmd). The required-env path is the one that `exec`s python, so it cannot be covered here; run it by hand in section 11. This is not a database exception, simply a no-port daemon that needs credentials.

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes no files; only stdout logging. Python bytecode disabled; `HOME=/config`.
- Draft says chart runs UID 0 with writable rootfs; neither is needed. Run as `apps` (568), read-only rootfs OK, no extra persistence (`persistence {}` in chart).
- Network egress to `dynamicdns.park-your-domain.com` is required.

## 10. Risks, caveats and open questions

- Draft caveats: Dynamic DNS must be enabled per domain in Namecheap; each host uses its own DDNS password (not the account password).
- No releases: the version is a commit; renovate git-refs will bump it. Tag is a 40-char SHA, which is unusual; consider shortening in CI if the repo expects semver-like tags.
- The password is part of the request URL; a failed request's exception text could show it in logs. Consider running with `APP_LOG_LEVEL` not DEBUG and mention in docs; do not patch upstream code.
- README says every 3 seconds, code default is 60 s: UNVERIFIED which is right; settings default follows the code reading.
- `requests` version and Python 3.15 compatibility UNVERIFIED.
- `docs`: the upstream image is `latest` only; no migration concerns.

## 11. Build and test steps

```sh
cd apps/namecheap-ddns
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
# No-credentials path: must exit 1 with the clear message
docker run --rm --read-only --tmpfs /tmp -v namecheap-ddns-probe-config:/config namecheap-ddns:<sha>
# Real path with dummy values (will log update failures, but must stay running):
docker run --rm -d --name namecheap-ddns-probe --read-only --tmpfs /tmp \
  -e APP_HOST=test -e APP_DOMAIN=example.com -e APP_PASSWORD=dummy \
  -v namecheap-ddns-probe-config:/config namecheap-ddns:<sha>
docker logs -f namecheap-ddns-probe
forgetool containers test --image namecheap-ddns:<sha> --config ./apps/namecheap-ddns/container-test.yaml
docker rm -f namecheap-ddns-probe; docker volume rm namecheap-ddns-probe-config
```

Readiness signal: the app's start log message (exact text UNVERIFIED), process still running, errors limited to expected per-target update failures from the dummy credentials (the loop catches them).

## 12. PR checklist

- Branch `feat/add-namecheap-ddns`, commit and PR title `feat(namecheap-ddns): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes; only applicable boxes checked.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Confirm bake VERSION == Dockerfile default, `bake --print` ok, `USER apps`, license shipped to `/usr/share/licenses/namecheap-ddns/`.
- Untested at planning time: build, runtime with real Namecheap credentials, arm64, Python 3.15 compatibility, `requests` pin.
