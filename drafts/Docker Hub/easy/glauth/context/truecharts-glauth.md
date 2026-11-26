# TrueCharts chart: glauth

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/glauth/values.yaml
- Fetched 2026-11-26 (chart directory listing not fetched in this run)

**What it is**
TrueCharts chart `glauth` (main image `glauth/glauth`).

**Container image (values.yaml)**
- repository: `docker.io/glauth/glauth`
- tag: `latest@sha256:075172abb6bbb675994c426c9f0eddd010cabb3a93dd44c45956e1bb206c5590`
- pullPolicy: `IfNotPresent`

**Security**
- securityContext: `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

**Service ports**
- `ldapport`: service 389/tcp to targetPort 389 (enabled).
- `ldapsport`: service 636/tcp to targetPort 636 (enabled).
- `main`: port 5555, protocol http (targetPort 5555).

**Persistence**
- `config` at `/app/config` (enabled).

**Env**
None defined.

**Contradictions with plan.md**
- plan.md section 9 says the chart mounts `/app/config` and runs as root with a writable rootfs. Matches.
- plan.md section 6 lists 3893 and 5555 as ports. The chart uses 389 and 636 at the service level, targetPort 389/636. The container will need to listen on 389/636 if the chart is kept as is; the plan moves the listener to 3893. Chart change required (already noted in plan.md section 9).
