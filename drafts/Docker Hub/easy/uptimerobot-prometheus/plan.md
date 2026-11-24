# uptimerobot-prometheus — implementation plan
> Source: ./draft.md · Target: apps/uptimerobot-prometheus/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | The repo has no releases and no tags (the README mentions `vX.Y.Z` tags, but the tags API returns none). Pin master commit `a64c74a3690080b2bfb65c947b050d8a76bef15b` (2026-11-15). The draft's old image `billimek/prometheus-uptimerobot-exporter:0.0.1` curls the master `exporter.py` unpinned and is outdated: upstream has since moved to the UptimeRobot v3 API. |
| Version scheme in this repo | `VERSION` = commit date `20261115`, plus `UPTIMEROBOT_COMMIT` = the sha (pattern of `apps/nextcloud-imaginary`) |
| Renovate | `datasource=git-refs depName=https://github.com/lekpamartin/uptimerobot_exporter versioning=loose` on the commit variable |
| License | Apache-2.0 (GitHub API; `LICENSE` is 11357 bytes, the standard text) |
| Source | https://github.com/lekpamartin/uptimerobot_exporter |
| Download | `https://raw.githubusercontent.com/lekpamartin/uptimerobot_exporter/<commit>/files/exporter.py` and `.../LICENSE` (architecture independent) |
| Checksum | UNVERIFIED: none published; the commit URL is immutable |
| Upstream Dockerfile | Repo `Dockerfile` (reviewed): python 3.15 alpine, installs only `requests` as a pure wheel into `/app/deps` (`PYTHONPATH=/app/deps`), `COPY files/exporter.py /app/exporter.py`, `USER nobody`, `EXPOSE 9705`, `CMD ["python3","/app/exporter.py"]`, healthcheck GETs `/` |
| Python needed | 3.8+, only `requests` at runtime (`requirements.txt` also lists lint/test tools: do not install them) |

Env vars (README table, confirmed in `exporter.py`): `UPTIMEROBOT_API_KEY` (required, a read-only key is enough), `UPTIMEROBOT_SERVER_NAME` (`0.0.0.0`), `UPTIMEROBOT_SERVER_PORT` (`9705`), `UPTIMEROBOT_CACHE_TTL` (`60`), `UPTIMEROBOT_RESPONSE_TIMES` (`false`), `UPTIMEROBOT_RESPONSE_TIME_WINDOW` (`3600`), `UPTIMEROBOT_API_URL` (`https://api.uptimerobot.com/v3`). Metrics at `/metrics`; the root path `/` does not call the UptimeRobot API.

## 2. Target layout

```
apps/uptimerobot-prometheus/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image
`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Upstream itself builds on Python 3.15, so the 3.15 base matches. The draft's alternative (plain ubuntu + apt `python3-requests`) is rejected, as it would add a second Python. Closest sibling: `apps/bazarr` for the venv install.

## 4. Dockerfile
1. `ARG VERSION`, `ARG UPTIMEROBOT_COMMIT` (default equal to the bake value), `USER root`, `ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 HOME=/tmp`.
2. `RUN mkdir -p /app/exporter /usr/share/licenses/uptimerobot-prometheus`; `curl -fsSL -o /app/exporter/exporter.py https://raw.githubusercontent.com/lekpamartin/uptimerobot_exporter/${UPTIMEROBOT_COMMIT}/files/exporter.py`; same for `LICENSE` into `/usr/share/licenses/uptimerobot-prometheus/LICENSE`.
3. `/app/venv/bin/pip install --no-cache-dir requests` (pure Python, same on both architectures; pin the version found at implementation time against the PyPI latest, 2.34.2 on 2026-11-23, and keep it in sync).
4. `chown -R root:root /app/exporter && chmod -R a+rX /app/exporter`.
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 9705`. No `VOLUME` (stateless; see section 9). No apt packages (the draft's `unzip` is unnecessary).

## 5. docker-bake.hcl
- `APP = "uptimerobot-prometheus"`
- `VERSION = "20261115"` and `UPTIMEROBOT_COMMIT = "a64c74a3690080b2bfb65c947b050d8a76bef15b"`, the latter preceded by `// renovate: datasource=git-refs depName=https://github.com/lekpamartin/uptimerobot_exporter versioning=loose`.
- `LICENSE = "Apache-2.0"`, `SOURCE = "https://github.com/lekpamartin/uptimerobot_exporter"`
- Standard four targets and default group; `args` carries both variables. Validate with `docker buildx bake --print`.

## 6. settings.yaml
Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/lekpamartin/uptimerobot_exporter"`.
- ports: `9705` tcp (required true).
- env (names as above, defaults equal to `start.sh` and upstream): `UPTIMEROBOT_API_KEY` (default `""`, `required: false` because the image must start without it, see section 7), `UPTIMEROBOT_SERVER_NAME` (`0.0.0.0`), `UPTIMEROBOT_SERVER_PORT` (`9705`), `UPTIMEROBOT_CACHE_TTL` (`60`), `UPTIMEROBOT_RESPONSE_TIMES` (`false`), `UPTIMEROBOT_RESPONSE_TIME_WINDOW` (`3600`), `UPTIMEROBOT_API_URL` (`https://api.uptimerobot.com/v3`), `TZ` (`Etc/UTC`).
- volumes: `[]` (stateless).
- dependencies: none (external service uptimerobot.com).

## 7. start.sh
```bash
#!/usr/bin/env bash
export UPTIMEROBOT_SERVER_NAME="${UPTIMEROBOT_SERVER_NAME:-0.0.0.0}"
export UPTIMEROBOT_SERVER_PORT="${UPTIMEROBOT_SERVER_PORT:-9705}"
if [[ -z "${UPTIMEROBOT_API_KEY:-}" ]]; then
  echo "WARNING: UPTIMEROBOT_API_KEY is not set, the exporter will not be able to read any monitors."
fi
cd /app/exporter
exec /app/venv/bin/python /app/exporter/exporter.py
```
The exporter reads the key from the environment itself (also an optional positional `apikey`, UNVERIFIED how it behaves with an empty key: it may exit at start). If the app exits without a key, then to satisfy "must start without env vars", start.sh MUST fall back to a placeholder key only for the no-key case and log that. Decide this during the first run test and keep the secret out of the process list (use the env var, never a CLI argument).

## 8. container-test.yaml
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
http:
- port: '9705'
  path: /
filePaths:
- /app/exporter/exporter.py
- /usr/share/licenses/uptimerobot-prometheus/LICENSE
```
Probe `/` rather than `/metrics`: upstream's own healthcheck uses `/` because it does not call the UptimeRobot API. The test has no env, so it cannot reach the API with a real key; `/metrics` with a valid key is a manual check.

## 9. Rootless and read-only-rootfs adaptations
- Upstream writes nothing: only in-memory caches. Bytecode is disabled and `HOME=/tmp`. The draft says "writes only to /tmp": no write is needed at all.
- Draft expectations (UID 568, rootfs writable false in the chart): `USER apps` plus a read-only rootfs works. No extra persistence, so no `/config` volume.

## 10. Risks, caveats and open questions
- The draft's source is stale: the old billimek image ran an older script. The v3 API exporter at master needs a v3-capable API key; document that.
- UptimeRobot rate limits (free plan: 10 requests/minute; each refresh costs 3 requests, plus one per up monitor with response times on). Defaults (cache 60 s) are safe for a 5 minute scrape interval.
- No tags: Renovate tracks the branch head, so every upstream commit creates an update PR. Alternative: a pinned digest without Renovate (maintainer decision).
- Behaviour with no API key at start is UNVERIFIED (see section 7).
- No blockers (pure Python, both architectures).

## 11. Build and test steps
```sh
cd apps/uptimerobot-prometheus
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name uptimerobot-prometheus-probe --read-only --tmpfs /tmp uptimerobot-prometheus:20261115
docker logs -f uptimerobot-prometheus-probe
curl -fsS http://<container-ip>:9705/
# with a real read-only key: -e UPTIMEROBOT_API_KEY=... and check /metrics has uptimerobot_up 1
docker rm -f uptimerobot-prometheus-probe
forgetool containers test --image uptimerobot-prometheus:20261115 --config ./apps/uptimerobot-prometheus/container-test.yaml
```
No `/config` volume is declared, so the "fresh /config volume" part of the protocol is not applicable. Readiness signal: the server start log line (text UNVERIFIED) and `/` answering 200.

## 12. PR checklist
- Branch `feat/add-uptimerobot-prometheus`, commit `feat(uptimerobot-prometheus): add new container`, target `main`.
- Fill in the PR template, check only the true boxes.
- `🤖 This PR is AI generated.` in the Notes section.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State untested: startup without an API key, `/metrics` against the real API, arm64, and the exact `requests` pin.
