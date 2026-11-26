# TrueCharts chart: filebrowser

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/filebrowser (directory listing)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/filebrowser/values.yaml
- Fetched 2026-11-26

**What it is**
TrueCharts chart `filebrowser` (`oci://oci.trueforge.org/truecharts/filebrowser`). Uses the common library. Chart has a `docs` folder.

**Container image (values.yaml)**
- repository: `docker.io/filebrowser/filebrowser`
- tag: `v2.63.23@sha256:a469ea076d4a1b4b1d86a41d130f2f536cd9da996a2b1fb39c0d7635f9d89b9a`
- pullPolicy: `IfNotPresent`

**Service/ports**
- main service port: `10187` (chart value; container port is set via `FB_PORT` template from this service port).

**Persistence**
- `config` at `/config`, `database` at `/database`, `data` at `/data` (all enabled).

**Env (main container)**
- `FB_ADDRESS`: `""`
- `FB_BASEURL`: `""`
- `FB_DATABASE`: `/database/filebrowser.db`
- `FB_CONFIG`: `/config/filebrowser.json`
- `FB_ROOT`: `/data`
- `FB_PORT`: templated from the main service port (10187)

**Probes**
Liveness, readiness and startup are all `http` at path `/`.

**Security**
No securityContext override in the fetched content (the chart defaults apply; not visible here).

**Contradictions with plan.md**
- plan.md section 9 says the chart's `/database` and `/data` mounts are the draft expectation. Matches (chart also mounts `/config`).
- plan.md section 7 uses `/config/settings.json`; the chart uses `FB_CONFIG=/config/filebrowser.json`. This is a chart choice, not a fact about the upstream image, so no edit.
- plan.md section 4/6 use container port 8080; the chart uses 10187 as its service port. Not a plan error; the chart will need the change described in plan.md section 10.
