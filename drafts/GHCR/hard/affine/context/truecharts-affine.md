# TrueCharts chart: affine

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/affine/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `affine` v4.0.0, appVersion 0.27.4. Description: open-source all-in-one workspace (docs, whiteboards, tasks). Category productivity.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.
- Chart-level dependencies: postgresql (enabled, operator type `vectors` for pgvector; username/db `affine`), valkey (enabled).

## Image (values.yaml)
- repository: `ghcr.io/toeverything/affine`
- tag: `0.27.4@sha256:c312116a134184947d98749c8a8e29f4e3bc97f4f2a51c9a3497f9baea2eec2b`
- pullPolicy: IfNotPresent

## Runtime security
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false

## Ports
| name | port | protocol |
| --- | --- | --- |
| main | 3010 | http |

## Env vars (main container)
| Env | Value |
| --- | --- |
| HOME | /root (hardcoded; comment: upstream image lacks HOME, os.homedir() returns "/") |
| NODE_ENV | production |
| PORT | "{{ .Values.service.main.ports.main.port }}" (3010) |
| REDIS_SERVER_HOST | from valkey dependency plainhost |
| REDIS_SERVER_PORT | "6379" |
| REDIS_SERVER_PASSWORD | secretKeyRef `<release>-valkeycreds` key valkey-password |
| DATABASE_URL | secretKeyRef `<release>-postgresqlcreds` key url |
- Commented (not set): AFFINE_SERVER_EXTERNAL_URL, AFFINE_SERVER_HOST, AFFINE_SERVER_HTTPS, AFFINE_INDEXER_ENABLED.

## Init container
- `affine-migration` (type init, imageSelector image): command `node ./scripts/self-host-predeploy.js`, same HOME/NODE_ENV/REDIS/DATABASE_URL env.

## Persistence
| name | mountPath (main and affine-migration) |
| --- | --- |
| config | /root/.affine/config |
| storage | /root/.affine/storage |

## Gotchas
- Chart comment: upstream predeploy script would mkdir "/.affine/config" if HOME unset, hence HOME=/root.
- pgvector required by AFFiNE (dependency operator type vectors).
- Probes not set in values.yaml.
