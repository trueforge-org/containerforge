# truecharts: wifi-card (chart 11.0.0, appVersion latest)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/wifi-card/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## Image
- repository `docker.io/bndw/wifi-card`, tag `latest@sha256:2b918b748dd2b88aa8642772b33d9bae42bd004c971a855181484ad10da2ec49`, pullPolicy IfNotPresent.

## Security
- readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0 (root).

## Service / ports
| Service | Port | Protocol | targetPort |
| --- | --- | --- | --- |
| main | 8888 | http | 80 |

## Env / persistence / probes
- No env vars, no persistence, no probes in values (chart defaults apply).

## Gotchas
- Chart serves on container port 80 (nginx default). The ContainerForge plan uses 8080 for the nginx base.
