# TrueCharts chart: rustdesk

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rustdesk/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rustdesk/values.yaml (fetched 2026-11-27)

## What it is
- Chart v5.0.0, appVersion 1.1.16. Category security. "rustdesk self-hosted".
- Sources: ghcr.io/rustdesk/rustdesk-server-s6, github rustdesk/rustdesk-server.
- Deps: common 32.8.5 (oci://oci.trueforge.org/truecharts)

## Image (values.yaml)
- `ghcr.io/rustdesk/rustdesk-server-s6`, tag `1.1.16@sha256:5974cd791a5aca6fbf01a167b37e7427db1d136e95b2710c33a34fdc9fea724c`, pullPolicy IfNotPresent

## Env (container main, set by chart)
| key | value |
| --- | --- |
| RELAY | localhost:21117 |
| ENCRYPTED_ONLY | 1 |

## Ports
| name | port | protocol | notes |
| --- | --- | --- | --- |
| main | 21117 | tcp | primary (relay) |
| id | 21116 | udp | hbbs |
| id2 | 21116 | tcp | hbbs |
| nat | 21115 | tcp | NAT test |
| client1 | 21118 | tcp | websocket (hbbr) |
| client2 | 21119 | tcp | websocket (hbbr) |

## Persistence
| name | mountPath |
| --- | --- |
| data | /data |

## Security context (chart)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false (chart defaults; not rootless).

## Upstream image notes (rustdesk-server 1.1.16 docker/Dockerfile)
Source URL: https://raw.githubusercontent.com/rustdesk-org/rustdesk-server/1.1.16/docker/Dockerfile (fetched 2026-11-27)
- Base `busybox:stable`. s6-overlay 3.2.0.0 (noarch + x86_64 tarballs fetched via ADD from GitHub). `ln -s /run /var/run`.
- `COPY rootfs /`. ENV RELAY=relay.example.com, ENCRYPTED_ONLY=0.
- EXPOSE 21115 21116 21116/udp 21117 21118 21119.
- HEALTHCHECK every 10s, timeout 5s: `/usr/bin/healthcheck.sh`.
- WORKDIR /data, VOLUME /data, ENTRYPOINT `["/init"]`.
- The s6 service run scripts under rootfs were not fetched (404 on the guessed path).
- License (raw LICENSE, 1.1.16): GNU AGPL v3.

## Ports per upstream docs
Source URL: https://rustdesk.com/docs/en/self-host (fetched 2026-11-27)
- hbbs: 21115 (NAT), 21116 (UDP+TCP, ID/registration), 21118 (websocket, optional)
- hbbr: 21117 (relay), 21119 (websocket, optional)
- 21115 and 21117 are minimum required; 21118/21119 normally only needed behind a reverse proxy with WebSocket.

## Gotchas
- Chart sets ENCRYPTED_ONLY=1 and RELAY=localhost:21117 (relay address advertised to clients should be set per deployment).
- Image is s6-based (`-s6` variant); entrypoint `/init`.
