# TrueCharts soft-serve values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/soft-serve/values.yaml
- Fetched 2026-11-27

## Image
- repository: `ghcr.io/charmbracelet/soft-serve`
- tag: `v0.12.4@sha256:740a313b3075ddbf4a24765cda8cfa1560c3fcad96e71d355dc365aeab351db6`
- pullPolicy: IfNotPresent

## Ports
- service main/main: 23231/tcp (SSH)

## Env vars
- No inline env. Container loads vars via `envFrom` secretRef `env-secret`.
- Soft-serve values listed: host `localhost`, key_path `/.ssh/soft_serve_server_ed25519`, init_admin_key `""`.

## Volumes/paths
- config → `/soft-serve`
- ssh → `/.ssh`
- repos → `/repos`

## User/UID, probes, securityContext
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false, fsGroup not set
- No probes.
