# dailynotes — implementation plan
> Source: ./draft.md · Target: apps/dailynotes/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `2026.10.29-00` (latest GitHub release, published 2026-10-29, no assets). Matches the draft tag. UNVERIFIED: that the upstream Dockerfile below is at this tag (it is pinned to commit `9d1a3a7e`, the tag's commit was not checked). |
| Docker Hub image in the chart | `docker.io/m0ngr31/dailynotes:latest` (digest `sha256:d2a9e353…`, amd64 only, 153096324 bytes, last updated 2025-12-11). Source: https://hub.docker.com/v2/repositories/m0ngr31/dailynotes/tags/latest |
| Renovate | Proposed: `datasource=github-releases depName=djedi/DailyNotes versioning=loose` (date-based tags are not strict semver). UNVERIFIED: not checked against Renovate's datasource docs. |
| License | MIT. Source: https://raw.githubusercontent.com/djedi/DailyNotes/9d1a3a7ea3597d93b2c8c4600437318a59eaa028/LICENSE (the README does not state a license). |
| Source URL | https://github.com/djedi/DailyNotes |
| Download | Tag tarball `https://github.com/djedi/DailyNotes/archive/refs/tags/${VERSION}.tar.gz`. No release asset. UNVERIFIED: the tarball was not fetched directly. |
| Per-arch download URLs | Same source tarball for amd64 and arm64. The app is built from source (pip + npm). UNVERIFIED: wheels on arm64 for the pinned Python packages. |
| Checksum source | None published. UNVERIFIED: no checksum source found. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/djedi/DailyNotes/9d1a3a7ea3597d93b2c8c4600437318a59eaa028/Dockerfile |
| Upstream build | Builder `FROM nikolaik/python-nodejs:python3.10-nodejs24`. Installs `build-essential` and `libffi-dev`. `pip install -r requirements.txt`. `cd client && npm install --prefer-offline --no-audit --legacy-peer-deps && npm run build` (output `/app/dist/`). |
| Upstream runtime | `FROM python:3.10-slim`. Installs `libffi-dev` and `curl`. Copies site-packages and `/usr/local/bin` from the builder. Copies `server.py`, `config.py`, `requirements.txt`, `run.sh`, `verify_env.py`, `verify_data_migrations.py`, `app`, `migrations`, `dist`. `chmod +x run.sh verify_env.py verify_data_migrations.py`. `mkdir -p /app/config`. |
| Upstream user | Not set: runs as root. No VOLUME. No ENV or ARG. |
| Upstream entrypoint | `ENTRYPOINT ["./run.sh"]`, no CMD. UNVERIFIED: the content of `run.sh` was not read. It may do ownership changes (`PUID`/`PGID`) and call `verify_env.py` and `verify_data_migrations.py`. |
| Port | 8000 (upstream `EXPOSE 8000`, README). The draft's 8080 is WRONG: 8080 is the dev Vue frontend only. The TrueCharts chart maps external 5000 to container 8000. |
| Health | Upstream `HEALTHCHECK curl -f http://localhost:8000/health`, interval 30s, timeout 10s, start-period 60s, retries 3. |
| Env vars (real, README) | `API_SECRET_KEY` (signs API tokens; auto-generated if unset). `DATABASE_URI` (SQLite if unset). `DB_ENCRYPTION_KEY` (encrypts data at rest; length multiple of 16; auto-generated if unset; changing it makes data unreadable). `PREVENT_SIGNUPS` (disables signup when set). `BASE_URL` (reverse-proxy subfolder). `PUID` / `PGID` (folder ownership IDs). `DEFAULT_TIMEZONE` (e.g. `America/Denver`). Source: https://raw.githubusercontent.com/djedi/DailyNotes/9d1a3a7ea3597d93b2c8c4600437318a59eaa028/README.md |
| Data and config | `/app/config` holds the database and the env file (README; upstream `mkdir`). The chart persists `/app/config` (TrueCharts `values.yaml`, UNVERIFIED for the chart at this version). |
| Chart values | https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dailynotes/values.yaml: image `m0ngr31/dailynotes:latest`, main port 5000 -> 8000, persistence `/app/config`, `runAsUser 0`, `runAsGroup 0`, `readOnlyRootFilesystem false`. |
| Dependencies | None (SQLite default). |

## 2. Target layout

- `apps/dailynotes/Dockerfile`
- `apps/dailynotes/docker-bake.hcl`
- `apps/dailynotes/settings.yaml`
- `apps/dailynotes/container-test.yaml`
- `apps/dailynotes/start.sh` (used only if `run.sh` cannot be used as is, see section 7)

No `defaults/`, `etc/`, `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). The app source is copied to `/app` (the upstream `WORKDIR`), so the upstream `/app/config` path is kept and remapped by symlink.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Fits because the app needs both Python (server) and Node (client build), and python-node provides both. Closest siblings: `apps/changedetection` (python-node, Python venv at `/app/venv`, pip install into it at build time, `USER apps`, `/config` volume) and `apps/thelounge` (node app on python-node).

Fallback: if a pinned Python package does not support 3.15, use `ghcr.io/trueforge-org/python-node:3.14.8@sha256:feb6e44439ea272f47b46a1511960f58af5df8056811c83973e2edec9b18afca`, which `apps/changedetection` uses for a litellm limit. UNVERIFIED: whether `requirements.txt` at this commit installs on 3.15.

Upstream Python is 3.10. The base Python is 3.15.2. UNVERIFIED: the pinned Python dependencies install on 3.15.

## 4. Dockerfile

1. `ARG VERSION`, `USER root`, `WORKDIR /app`.
2. Build dependencies only if a pip package has no wheel for the arch. Install `build-essential` and `libffi-dev` in the same `RUN`, then purge them after the install (as `apps/changedetection` does). The base may already have them: check first.
3. Download and extract the tag (no git history):

```dockerfile
RUN curl -fL -o /tmp/dailynotes.tar.gz \
      "https://github.com/djedi/DailyNotes/archive/refs/tags/${VERSION}.tar.gz" && \
    tar xzf /tmp/dailynotes.tar.gz -C /app --strip-components=1 && \
    rm /tmp/dailynotes.tar.gz
```

4. Python server, installed into the bundled venv at build time (python-runtime rule: `/app/venv` is read-only at runtime, so no runtime install):

```dockerfile
RUN /app/venv/bin/pip install -U --no-cache-dir -r /app/requirements.txt
```

   `PIP_NO_CACHE_DIR=1` is already set by the base; keep it. Caches go to `/tmp`.

5. Client build with npm (cache to `/tmp`, never `/config`):

```dockerfile
RUN cd /app/client && \
    npm_config_cache=/tmp/npm npm install --prefer-offline --no-audit --legacy-peer-deps && \
    npm run build
```

   The output goes to `/app/dist/` (upstream). UNVERIFIED: the build output path in `client/vite.config` (or equivalent) at this tag.

6. Remove the client sources and caches the runtime does not need, then clean up:

```dockerfile
RUN rm -rf /app/client/node_modules /tmp/* && \
    chown -R apps:apps /app && chmod -R 755 /app
```

   Keep `/app/venv` owned by `apps` as well (read-only at runtime, python-runtime rule).

7. Map the upstream data path to `/config`:

```dockerfile
RUN ln -s /config /app/config
```

   Dangling until `/config` exists (the volume). The DB and the env file (incl. auto-generated keys) go into `/config`.

8. License: `mkdir -p /usr/share/licenses/dailynotes && cp /app/LICENSE /usr/share/licenses/dailynotes/LICENSE`. The LICENSE file is at the repo root (fetched at `9d1a3a7e`).
9. Tail:

```dockerfile
ENV HOME=/config
USER apps
COPY --chmod=0755 . /

EXPOSE 8000
VOLUME /config
WORKDIR /app
```

## 5. docker-bake.hcl

Copy the layout of `apps/adguardhome-sync/docker-bake.hcl`:

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "dailynotes"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=djedi/DailyNotes versioning=loose
  default = "2026.10.29-00"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/djedi/DailyNotes"
}
```

Then the standard `group "default"`, `image`, `image-local` (`tags = ["${APP}:${VERSION}"]`) and `image-all` (`linux/amd64`, `linux/arm64`). The Dockerfile `ARG VERSION` has no default; the value comes from bake. Validate with `docker buildx bake --print` from `apps/dailynotes/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/djedi/DailyNotes"
ports:
  - port: 8000
    protocol: tcp
    required: true
env:
  - name: API_SECRET_KEY
    default: ""
    required: false
  - name: DATABASE_URI
    default: ""
    required: false
  - name: DB_ENCRYPTION_KEY
    default: ""
    required: false
  - name: PREVENT_SIGNUPS
    default: ""
    required: false
  - name: BASE_URL
    default: ""
    required: false
  - name: DEFAULT_TIMEZONE
    default: "Etc/UTC"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- Only the variables the README documents. Empty defaults mean "unset", so the app's own auto-generation applies.
- `PUID` / `PGID` are left out: this image runs as `apps` (568), so the upstream ownership switch does not apply. Add them only if the upstream `run.sh` reads them and the port is kept (UNVERIFIED).
- `DB_ENCRYPTION_KEY` and `API_SECRET_KEY` are secrets. Keep them out of the process list where possible (the app reads them from the environment; the README does not say whether they are logged). UNVERIFIED.
- No `dependencies`.

## 7. start.sh

Preferred: no `start.sh`. Use upstream `run.sh` as the entrypoint if it works as `apps` (read it at the pinned commit first, UNVERIFIED). Then `Dockerfile` ends with `ENTRYPOINT ["/app/run.sh"]` and the `COPY . /` rule brings in the rest.

If `run.sh` needs root (`PUID`/`PGID` chown, writes under `/app`), replace it with `apps/dailynotes/start.sh`:

```bash
#!/usr/bin/env bash

mkdir -p /config
cd /app || exit 1

python3 verify_env.py || exit 1
python3 verify_data_migrations.py || exit 1

exec /app/venv/bin/python server.py
```

- Idempotent. Creates `/config` only if missing. Writes nothing into `/app`.
- The server entry (`server.py` with a `uvicorn`/`gunicorn` launch, or the `run.sh` command) is UNVERIFIED: read `run.sh` and `server.py` at the pinned commit before writing the final command.
- Use `exec` so the server is PID 1 under `tini`.
- The server must bind `0.0.0.0:8000`. UNVERIFIED: the bind address in `server.py`/`run.sh`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8000'
http:
- port: '8000'
  path: /health
filePaths:
- /app/server.py
- /app/dist/index.html
- /app/venv/bin/python
- /usr/share/licenses/dailynotes/LICENSE
```

- `timeoutSeconds: 180` is the most common value across `apps/*/container-test.yaml`. Upstream allows a 60 s start-period.
- `/health` is the upstream HEALTHCHECK path, so the probe matches upstream behaviour.
- `/app/dist/index.html` is UNVERIFIED: confirm the built entry file name at the pinned tag.
- No env-gated code paths are assumed. `DB_ENCRYPTION_KEY` and `API_SECRET_KEY` are auto-generated by the app. If the generated-key path writes a file under `/config`, that is tested by the empty-`/config` probe in section 11.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/config` (DB, env file, generated keys) | `/app/config` -> `/config` (build-time symlink) |
| Upstream runs as root | `USER apps` (568). `/config` is owned by `apps` in the base |
| Pip and npm caches | `/tmp` (`npm_config_cache=/tmp/npm`; pip `PIP_NO_CACHE_DIR=1` from the base) |
| Runtime writes under `/app` (logs, migrations, `dist`) | UNVERIFIED for every code path. Test with `--read-only --tmpfs /tmp` |

Security expectations from the draft, reconciled:

- Chart: `runAsUser 0`, `runAsGroup 0`. This image: `apps`, not root. Existing data under the chart's `/app/config` is root-owned on the old PVC. Users must `chown` it to 568 or run once with the old owner. Document in the PR.
- `readOnlyRootFilesystem`: chart `false`. Plan is compatible with `--read-only --tmpfs /tmp` (to be proven).
- `privileged`: no.
- Persistence: single `/config` volume (the chart uses `/app/config`, remapped here).

## 10. Risks, caveats and open questions

- Port: the draft's 8080 is wrong. Use 8000 (section 1).
- UNVERIFIED: `run.sh`, `verify_env.py`, `verify_data_migrations.py` contents at `9d1a3a7e`. The final command depends on them.
- UNVERIFIED: whether `9d1a3a7e` is the commit of tag `2026.10.29-00`. The Dockerfile reviewed is pinned to `9d1a3a7e`.
- Python: upstream 3.10, base 3.15.2. Pinned packages may not have 3.15 wheels. Fallback in section 3.
- Node: the base Node version is UNVERIFIED against the client's `engines` field. The upstream builder used Node 24.
- `--legacy-peer-deps` is used upstream. Keep it. It hides peer-dependency conflicts; do not change it in this PR.
- Secrets: a changed `DB_ENCRYPTION_KEY` makes the data unreadable. Do not generate new keys on each start. The auto-generated keys must persist in `/config`.
- arm64: no published arm64 image upstream (`m0ngr31/dailynotes` is amd64 only). Building from source covers both arches; arm64 native deps UNVERIFIED.
- Fork image `xhenxhe/dailynotes` is mentioned in the README and was not checked. Not used.
- Blockers: none found. Root upstream and a two-runtime build are the main cost, not a blocker.

## 11. Build and test steps

```sh
cd apps/dailynotes
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name dailynotes-probe --read-only --tmpfs /tmp \
  -v dailynotes-probe-config:/config dailynotes:2026.10.29-00
docker logs -f dailynotes-probe
forgetool containers test --image dailynotes:2026.10.29-00 --config ./apps/dailynotes/container-test.yaml
docker rm -f dailynotes-probe; docker volume rm dailynotes-probe-config
```

- Expected readiness signal: the server log line for the bound port 8000 (exact text UNVERIFIED: read it from the server at the pinned tag), and `GET /health` returns 200.
- After the first start, `/config` must contain the database and the env file. Restart with the same volume: the generated keys must be the same (check the key file/env does not change).
- Not tested by this plan: `BASE_URL` (reverse-proxy subfolder), `PREVENT_SIGNUPS`, `DATABASE_URI` with an external DB, arm64, data migration from the chart's root-owned PVC.

## 12. PR checklist

- Branch `feat/add-dailynotes`, commit `feat(dailynotes): add new container`, PR title the same, target `main`.
- Tell the user the CLA is needed: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- State what was not tested: arm64, the `BASE_URL` and `PREVENT_SIGNUPS` paths, external DB, migration from a root-owned PVC, unless they were run.
- `docker buildx bake --print` passes; `VERSION` in `docker-bake.hcl` equals the build's version; no assertion weakened.
