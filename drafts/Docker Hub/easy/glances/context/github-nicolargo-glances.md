# nicolargo/glances (GitHub)

**Source URL(s) + fetch date**
- https://github.com/nicolargo/glances (repo, draft source link)
- https://raw.githubusercontent.com/nicolargo/glances/e907519c4a446da33b6968dba8f1c3b84a3379df/docker-files/ubuntu.Dockerfile (draft's Dockerfile link, at the pinned commit)
- https://raw.githubusercontent.com/nicolargo/glances/v4.5.9/COPYING (plan.md)
- README at `v4.5.9` and `develop` returned 404; not summarised.
- Fetched 2026-11-26

**What it is**
Cross-platform system monitor (CPU, memory, disk, network, processes and more) with console, web UI and REST API. Exports to CSV/JSON or time-series databases. License LGPL-3.0 (COPYING is the GNU LGPL v3 text).

**Install/build steps and build deps (upstream `docker-files/ubuntu.Dockerfile`)**
- `ARG IMAGE_VERSION=24.04`, `ARG PYTHON_VERSION=3.12` (global); the file warns to set the Python version per Ubuntu release.
- Stage `base`: `FROM ubuntu:${IMAGE_VERSION}`; `apt-get install --no-install-recommends python3 curl lm-sensors wireless-tools smartmontools net-tools tzdata`; apt clean and remove lists.
- Stage `build`: `apt-get upgrade`; install `python3-dev python3-venv python3-pip python3-wheel libzmq5 musl-dev build-essential`; `python3 -m venv --without-pip venv`; copies `requirements.txt docker-requirements.txt webui-requirements.txt optional-requirements.txt`.
- Stage `buildMinimal`: `pip install --target=/venv/lib/python${PYTHON_VERSION}/site-packages` of `requirements.txt`, `docker-requirements.txt`, `webui-requirements.txt`.
- Stage `buildFull`: same target with `requirements.txt` and `optional-requirements.txt`.
- Stage `release`: `FROM base`; copies `docker-compose/glances.conf` to `/etc/glances/glances.conf`, `glances/.` to `/app/glances/`, `docker-bin.sh` to `/usr/local/bin/glances`; `ENV PATH="/venv/bin:$PATH"`; `EXPOSE 61209 61208` (XMLRPC / WebUI); `WORKDIR /app`; `CMD /venv/bin/python3 -m glances $GLANCES_OPT`.
- Stage `minimal` (`FROM release`, `COPY --from=buildMinimal /venv /venv`); stage `full` (`FROM release`, adds `libzmq5`, `COPY --from=buildFull /venv /venv`); stage `dev` (`FROM full`, `LOG_CFG=/app/docker-logger.json`).

**Runtime deps**
Python 3 venv, glibc (Ubuntu base), plus the Ubuntu packages above for optional plugins (sensors, wireless, SMART, net tools).

**Binaries/entrypoint/CLI flags**
- Upstream: `/usr/local/bin/glances` wrapper (`docker-bin.sh`, not fetched); CMD runs `python3 -m glances $GLANCES_OPT`.
- `-w` starts the web server (per Docker Hub and docs).

**Env vars**

| Name | Default | Notes |
| --- | --- | --- |
| `GLANCES_OPT` | unset in Dockerfile; chart sets `-w -p 61208` | Passed as CLI args to glances. |
| `LOG_CFG` | unset (set only in `dev` stage) | Log config path. |
| `PATH` | `/venv/bin:$PATH` | Set in release stage. |

**Ports**
`61209` (XMLRPC, from EXPOSE) and `61208` (web UI and API).

**Volumes/paths and persistent data**
- Upstream Dockerfile has no VOLUME. Config path baked in: `/etc/glances/glances.conf`. App code at `/app/glances`. Venv at `/venv`.
- Hub run examples add the Docker socket (`/var/run/docker.sock:ro`) and a glances.conf bind mount to `/glances/conf/glances.conf` (Hub, not the Dockerfile).

**User/UID & permissions**
No USER instruction in the Dockerfile; runs as root. The chart sets runAsUser 1000. No commented-out USER line is present in the fetched file.

**Config files and formats**
`glances.conf` (INI-style). Baked default at `/etc/glances/glances.conf`. Config location details were not confirmed (docs index only).

**Healthcheck/readiness endpoints**
None in the Dockerfile. Plan.md names `/api/4/status`; not verified here.

**Version/release info and asset naming**
Image tags on Docker Hub (`ubuntu-latest-full`, `latest`, `dev`, specific versions such as 4.3.1). Chart pins `ubuntu-4.3.0.8-full`. No release asset needed (pip package).

**Arch support**
Not stated in the Dockerfile.

**License**
LGPL-3.0 (COPYING: "GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007").

**Gotchas**
- Hub docs run the container with `--pid host` and `--network host` for host metrics; the chart comments out hostPID and hostNetwork.
- Docker plugin needs the Docker socket; the Dockerfile has no comment about that.

**Contradictions with plan.md**
- plan.md section 1 says `full` adds `libzmq5 libvirt-clients`. Fetched Dockerfile: `full` adds `libzmq5` only. Corrected in plan.md.
- plan.md section 1 says base apt packages omit `wireless-tools`. Corrected in plan.md.
- plan.md section 1 says upstream has a commented-out `# USER glances` line with a Docker plugin note. The fetched Dockerfile has no USER instruction and no such comment. Corrected in plan.md.
- plan.md section 1 `EXPOSE 61209 61208`, `CMD ... $GLANCES_OPT`, `PATH` ENV, root user: match.
