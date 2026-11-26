# lnxd/github-backup (GitHub, the draft's source repository)

**Source URL(s) + fetch date**
- https://github.com/lnxd/github-backup (draft source link; repo page not fetched directly)
- https://raw.githubusercontent.com/lnxd/github-backup/master/Dockerfile
- https://raw.githubusercontent.com/lnxd/github-backup/master/README.md
- Fetched 2026-11-26

**What it is**
Old Docker packaging of a GitHub backup script (`github-backup.py`, README calls it `backup.py`), shipped for Unraid. Given a token and a destination directory it clones every repository the token can reach; later runs refresh existing backups and pick up new repositories. Scheduled via `backup.sh`.

**Install/build steps and build deps (Dockerfile)**
- `FROM alpine:3.9`
- `RUN mkdir -p /home/docker/github-backup/config`
- `ENV HOME /home/docker`
- COPY `github-backup.py`, `requirements.txt`, `config.json.example`, `backup.sh` into `/home/docker/github-backup/`
- `WORKDIR /home/docker/github-backup`
- `RUN apk add --no-cache python3 py3-pip git; pip3 install --upgrade pip; pip3 install -r requirements.txt; chmod -R 777 /home/docker; chown -R 99:98 /home/docker; chmod +x backup.sh`
- `USER 99:98`
- `CMD ["./backup.sh"]`
- No ARG, VOLUME, EXPOSE or ENTRYPOINT.

**Runtime deps**
python3, py3-pip, git (Alpine packages), Python packages from `requirements.txt` (not fetched).

**Binaries/entrypoint/CLI flags**
`./backup.sh` (CMD). Script's contents not fetched. Python script `github-backup.py` (per Dockerfile).

**Env vars**
Not documented in the README. The TrueCharts chart sets `SCHEDULE` and `TOKEN` (see truecharts summary), which implies the image reads them through `backup.sh` (script not fetched, so unverified).

**Ports**
None.

**Volumes/paths and persistent data**
- Image has no VOLUME. Paths used by the image: `/home/docker/github-backup` (app), `/home/docker/github-backup/config` (config dir), and a destination directory for backups. The chart mounts `/home/docker/backups` and `/home/docker/github-backup/config/`.

**User/UID & permissions**
Runs as `99:98`. Build makes `/home/docker` world-writable (`chmod -R 777`) and owned by `99:98`. `HOME=/home/docker`.

**Config files and formats**
`config.json.example` is copied in; README gives no format. Plan.md says the token is written into `config.json` by `sed` (script not fetched; unverified).

**Healthcheck/readiness endpoints**
None.

**Version/release info and asset naming**
No version pinning in the Dockerfile; Alpine 3.9 is end-of-life. README says installation is via Unraid Community Applications.

**Arch support**
Not stated. Hub page does not list architectures.

**Gotchas**
- README names the script `backup.py`; the Dockerfile copies `github-backup.py`. Inconsistent; the Dockerfile is the authoritative source.
- README says the token needs `repo` scope (classic) or `public_repo` for public only.
- Alpine 3.9 base is old; the image is not reproducible from a maintained source.

**Contradictions with plan.md**
- plan.md section 1 says the lnxd image uses env `TOKEN` and `SCHEDULE` (seconds) and paths `/home/docker/github-backup/config/config.json` and `/home/docker/backups`, runs as UID 99:98, and that the Dockerfile is alpine 3.9 with `pip3 install -r requirements.txt` and `CMD ./backup.sh`. The Dockerfile matches (alpine 3.9, pip3 requirements, `CMD ["./backup.sh"]`, `99:98`). The `TOKEN`/`SCHEDULE` names and `config.json` path rely on `backup.sh`, which was not fetched; unverified.
- plan.md section 1 says the lnxd repo is archived 2022-09-06 and MIT. Not verified in this run.
