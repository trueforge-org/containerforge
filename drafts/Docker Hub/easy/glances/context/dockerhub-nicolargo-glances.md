# nicolargo/glances (Docker Hub)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/nicolargo/glances
- Fetched 2026-11-26

**What it is**
Glances container for host and container monitoring, console or web UI + API. Page lists 100M+ total pulls.

**Tags listed**
- `latest-full`, `ubuntu-latest-full`: full images with all dependencies.
- `latest`, `ubuntu-latest`: basic images, minimal dependencies (FastAPI and Docker).
- `dev`, `ubuntu-dev`: development branch build, possibly unstable.
- Specific versions can be pulled (example 4.3.1).
- Latest tag: 43.3 MB, updated about 19 days before fetch; repo updated 1 day before fetch.

**Architectures**
Not stated.

**Source link**
No source repository link on the page.

**Run examples**
- Console: `docker run --rm -v /var/run/docker.sock:/var/run/docker.sock:ro --pid host --network host -it nicolargo/glances:ubuntu-latest-full`
- Web: `docker run -d --restart="always" -p 61208-61209:61208-61209 -e GLANCES_OPT="-w" -v /var/run/docker.sock:/var/run/docker.sock:ro --pid host nicolargo/glances:ubuntu-latest-full`
- Custom config: mount `glances.conf` to `/glances/conf/glances.conf`.

**Env vars**
`GLANCES_OPT` (startup parameters, for example `-w`).

**Volumes**
Docker socket (`ro`), Podman socket path `/run/user/1000/podman/podman.sock`, and `glances.conf` at `/glances/conf/glances.conf`.

**Ports**
61208-61209 in web mode. Console mode uses host networking.

**Contradictions with plan.md**
- The Hub run examples mount the config at `/glances/conf/glances.conf`, while the upstream Dockerfile bakes the config at `/etc/glances/glances.conf`. Both are image-specific; plan.md section 7 uses `/config/glances.conf` (our own choice). No edit.
- The Hub pages set `--pid host`; plan.md section 9 says host PID is off by default in the chart. Not an error.
