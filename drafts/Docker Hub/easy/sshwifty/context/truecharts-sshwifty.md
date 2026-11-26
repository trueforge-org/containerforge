# TrueCharts sshwifty chart (values.yaml)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sshwifty/values.yaml (fetched 2026-11-26)

## What it is
TrueCharts Helm chart `sshwifty`. Single `main` workload, port 8182.

## Image used by chart
`docker.io/niruix/sshwifty` tag `latest@sha256:f62f80a6104caad0c49624cef383e2da1bbd27f5500b11bf92bba4f50f7d86b1`, pullPolicy IfNotPresent.

## Env vars set by chart
- `SSHWIFTY_HOSTNAME`: "" (accept all hosts)
- `SSHWIFTY_SHAREDKEY`: "" (no web password)
- `DialTimeout`: 10 (not an SSHWIFTY_ name; no effect as env)
- `SSHWIFTY_LISTENPORT`: from service port (8182)
- `SSHWIFTY_LISTENINTERFACE`: 0.0.0.0
- `SSHWIFTY_INITIALTIMEOUT`: 3; `SSHWIFTY_READTIMEOUT`: 60; `SSHWIFTY_WRITETIMEOUT`: 60; `SSHWIFTY_HEARTBEATTIMEOUT`: 20
- `SSHWIFTY_READDELAY`: 10; `SSHWIFTY_WRITEELAY`: 10
- SOCKS5, TLS file and PRESETS variables are commented out.

## Security
securityContext.container: readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0.

## Probes
liveness, readiness and startup all HTTP path `/`.

## Service
main: http, port 8182.

## Persistence / secrets
None defined.

## Contradictions with plan.md
- Chart runs as root with probes on `/`; plan.md targets `apps` user and a read-only rootfs, with no persistence (consistent with plan.md section 9).
- Chart sets `DialTimeout` as a plain key (not an env var name), so it has no effect.
