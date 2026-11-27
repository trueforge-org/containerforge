# TrueCharts chart: neko

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/neko/{Chart.yaml,values.yaml} (fetched 2026-11-27)

## What it is
- Chart `neko` v13.0.0, appVersion 3.2.0, category media, keywords neko/video.
- Description: "A self hosted virtual browser that runs in Chart".
- Depends on `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).
- Sources: ghcr.io/m1k1o/neko/{brave,chromium,firefox,google-chrome,microsoft-edge,remmina,tor-browser}.
- kubeVersion >=1.33.0-0; min helm 3.14; max helm 4.1; max k8s 1.35.0.

## Images (all tag 3.2.0@sha256:..., pullPolicy IfNotPresent)
| Key | Repository |
| --- | --- |
| image (default) | ghcr.io/m1k1o/neko/firefox |
| braveImage | ghcr.io/m1k1o/neko/brave |
| chromeImage | ghcr.io/m1k1o/neko/google-chrome |
| chromiumImage | ghcr.io/m1k1o/neko/chromium |
| edgeImage | ghcr.io/m1k1o/neko/microsoft-edge |
| remminaImage | ghcr.io/m1k1o/neko/remmina |
| torImage | ghcr.io/m1k1o/neko/tor-browser |
| vivaldiImage | ghcr.io/m1k1o/neko/vivaldi |
| vlcImage | ghcr.io/m1k1o/neko/vlc |
| xfceImage | ghcr.io/m1k1o/neko/xfce |

## Service / ports
| Name | Port | Protocol | Notes |
| --- | --- | --- | --- |
| main | 10294 | http | NEKO_BIND=":10294" |
| mux.tcp | 52100 | tcp | NEKO_TCPMUX |
| mux.udp | 52100 | udp | NEKO_UDPMUX (same port as tcp) |

## Env (container `main`)
| Env | Value / source |
| --- | --- |
| NEKO_BIND | `:<service.main.port>` (10294) |
| NEKO_PATH_PREFIX | "/" |
| NEKO_NAT1TO1 | neko.ip ("0.0.0.0" default) |
| NEKO_TCPMUX / NEKO_UDPMUX | 52100 |
| NEKO_FILE_TRANSFER_ENABLED | true |
| NEKO_FILE_TRANSFER_PATH | persistence.downloads.mountPath |
| NEKO_CONTROL_PROTECTION | false |
| NEKO_IMPLICIT_CONTROL | false |
| NEKO_LOCKS | [] (joined by space) |
| NEKO_PASSWORD | secret env-secrets NEKO_PASSWORD (from neko.auth.user_pass) |
| NEKO_PASSWORD_ADMIN | secret env-secrets NEKO_PASSWORD_ADMIN (from neko.auth.admin_pass) |
| NEKO_PROXY | false |
| NEKO_SCREEN | "1920x1080@30" |
| NEKO_CORS | "*" |

## Persistence
| Name | mountPath |
| --- | --- |
| downloads | /home/neko/Downloads |

## Security
- securityContext.container: readOnlyRootFilesystem false; runAsUser 0; runAsGroup 0.

## Gotchas
- Chart env names (NEKO_BIND, NEKO_PASSWORD, NEKO_SCREEN, NEKO_TCPMUX) differ from the v3 names in upstream docker-compose.yaml (NEKO_DESKTOP_SCREEN, NEKO_WEBRTC_EPR, NEKO_MEMBER_MULTIUSER_*). See neko-docs-v3-quickstart.md. Unverified which set v3.2.0 honours.
