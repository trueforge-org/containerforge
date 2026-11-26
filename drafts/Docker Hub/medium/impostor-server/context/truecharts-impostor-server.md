# TrueCharts chart: impostor-server
Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/impostor-server (raw values.yaml + Chart.yaml fetched 2026-11-26)

## Chart.yaml
- version 14.0.0, appVersion 1.10.10; common 32.8.5; min helm 3.14, max helm 4.1

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/aeonlucid/impostor |
| image.tag | v1.10.10@sha256:1a336acf385d7e4a18595222e33670541bf416ad08eac292edfaeb29ee0231ab |
| nightlyImage.tag | nightly@sha256:30528e85502dfc441011b2f497f362955a8837e4bc794b02b4ecc94e2ee1d06a (not referenced: container uses imageSelector image) |
| service.main.ports.main | protocol udp, port 22023 -> targetPort 22023 |

## Env (workload.main container)
| Env | Value |
| --- | --- |
| IMPOSTOR_Server__PublicIp | "127.0.0.1" |
| IMPOSTOR_Server__ListenIp | "0.0.0.0" |
| IMPOSTOR_AntiCheat__Enabled | true |
| IMPOSTOR_AntiCheat__BanIpFromGame | true |
| IMPOSTOR_Debug__GameRecorderEnabled | false |
| IMPOSTOR_Debug__GameRecorderPath | "" |

## Probes
- liveness, readiness, startup: all disabled

## Other
- No persistence, no secret, no securityContext override (readOnlyRootFilesystem not set in chart). Runs with image default user.
- Only a UDP port is declared; upstream docs also use TCP 22023 for the HTTP service (see impostor-running-the-server.md).

## Gotchas
- PublicIp default 127.0.0.1 must be overridden to the public address for real play.
