# TrueCharts chart: glances

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/glances/values.yaml
- Fetched 2026-11-26 (the chart directory listing was not fetched in this run)

**What it is**
TrueCharts chart `glances` (main image `nicolargo/glances`).

**Container image (values.yaml)**
- repository: `docker.io/nicolargo/glances`
- tag: `ubuntu-4.3.0.8-full@sha256:4519127ae8fc511a46830b753fadfa16151023688bb7d80d568ec34ef57bd359`
- pullPolicy: `IfNotPresent`

**Security**
- securityContext: `runAsUser: 1000`, `runAsGroup: 1000`; `PUID: 1000` also set. `readOnlyRootFilesystem` and `privileged` not specified.

**Ports**
- Service `main`, port `main`: `61208`.

**Persistence**
None defined.

**Env**
- `GLANCES_OPT`: `-w -p {{ .Values.service.main.ports.main.port }}` (resolves to `-w -p 61208`).

**Other**
- hostPID and hostNetwork pod options are commented out (described as for running tasks and host network stats).

**Contradictions with plan.md**
- plan.md section 6/9 says the chart runs as UID 1000. Matches.
- plan.md section 8 test uses the default `-w`. The chart passes `-p 61208` as well; the port matches the plan's declared port.
- The chart image is the 4.3.0.8 full tag; the plan's 4.5.9 pip version is newer. Intended by the plan (no edit).
