# TrueCharts chart: factorio

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/factorio (directory listing and README)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/factorio/values.yaml
- Fetched 2026-11-26

**What it is**
TrueCharts chart `factorio` (`oci://oci.trueforge.org/truecharts/factorio`). Uses the common library chart. Not maintained by upstream.

**Container image (values.yaml)**
- repository: `docker.io/factoriotools/factorio`
- tag: `stable@sha256:a0c019b7608975a58f1694de54a2326e13a5aa2d123c18f48e5396181e366e28`
- pullPolicy: `IfNotPresent`

**Security/runtime settings**
- securityContext: `runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`. `privileged` not set.

**Ports**
- main: `34197/udp` (`PORT` from `service.main.ports.main.port`).
- rcon: `27015/tcp` (enabled).

**Persistence**
- `config` volume mounted at `/factorio`.

**Env vars**
- `PORT`, `RCON_PORT` (templated from service values)
- `GENERATE_NEW_SAVE`: `false`
- `LOAD_LATEST_SAVE`: `true`
- `SAVE_NAME`: `_autosave1`
- `TOKEN`: from secret `env-secrets`, key `TOKEN`
- `UPDATE_MODS_ON_START`: empty
- `USERNAME`: empty

**Probes**
Liveness, readiness and startup are all TCP probes on the RCON port. Health depends on RCON being reachable.

**Contradictions with plan.md**
- plan.md says the draft's chart sets `runAsNonRoot false`, root and read-only false. Matches.
- plan.md section 9 says the chart mounts `/factorio`, which matches.
- plan.md section 8 notes the tcp probe on RCON; the chart's probes use the same port, which agrees with plan.md's `tcp` test choice.
