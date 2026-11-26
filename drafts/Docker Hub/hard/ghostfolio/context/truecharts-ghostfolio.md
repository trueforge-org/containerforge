# TrueCharts ghostfolio chart (reference only)

Source URLs:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ghostfolio (fetched 2026-11-26, file list + README)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ghostfolio/values.yaml (fetched 2026-11-26)

## Chart layout
- Files: Chart.yaml, values.yaml, values.schema.json, CHANGELOG.md, README.md, icons, templates/
- Install: OCI `oci://oci.trueforge.org/truecharts/ghostfolio`
- Upstream is not maintained by this chart. Common library chart supplies shared options.

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | docker.io/ghostfolio/ghostfolio |
| tag | 3.100.0@sha256:1bc2ff4740410dd2c3bdde95738268f4c619cf4eeec491e3967bec18c95130b1 |
| pullPolicy | IfNotPresent |

## Ports
- service.main.ports.main: port 3333 -> targetPort 3333

## Env (values.yaml)
| Name | Source |
| --- | --- |
| ALPHA_VANTAGE_API_KEY | secret env-secrets |
| ACCESS_TOKEN_SALT | secret ghostfolio-secrets |
| JWT_SECRET_KEY | secret ghostfolio-secrets |
| DATABASE_URL | postgres creds secret (templated name) |
| REDIS_HOST | valkey creds secret (templated) |
| REDIS_PASSWORD | valkey creds secret (templated) |
| REDIS_PORT | "6379" |

## Security context
- container: runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0
- No persistence block in values.yaml.

## Gotchas
- Chart runs the container as root and writable rootfs. Not a model for a rootless image.
- Chart pins the same tag as the Dockerfile upstream release (3.100.0).
- ALPHA_VANTAGE_API_KEY appears in the chart but not in the upstream README env table.
