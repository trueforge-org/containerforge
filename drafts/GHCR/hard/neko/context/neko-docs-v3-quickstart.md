# Source: neko docs v3 quick start + master docker-compose.yaml

Source URL(s) + date: https://neko.m1k1o.net/docs/v3/quick-start (200, fetched 2026-11-27); https://raw.githubusercontent.com/m1k1o/neko/master/docker-compose.yaml (200, fetched 2026-11-27)

## Quick start
- Download docker-compose.yaml from master and start it. No other config detail in the page text.

## docker-compose.yaml (master, uses :latest tag)
| Item | Value |
| --- | --- |
| image | ghcr.io/m1k1o/neko/firefox:latest |
| shm_size | 2gb |
| ports | 8080:8080 (tcp); 52000-52100:52000-52100/udp |
| NEKO_WEBRTC_EPR | 52000-52100 |
| NEKO_DESKTOP_SCREEN | 1920x1080@30 |
| NEKO_MEMBER_MULTIUSER_USER_PASSWORD | neko (example) |
| NEKO_MEMBER_MULTIUSER_ADMIN_PASSWORD | admin (example) |
| NEKO_WEBRTC_NAT1TO1 | <your-IP> |

## Gotchas
- Master compose uses v3 env names (NEKO_DESKTOP_SCREEN, NEKO_WEBRTC_EPR, NEKO_MEMBER_MULTIUSER_*). TrueCharts chart uses NEKO_SCREEN, NEKO_TCPMUX, NEKO_PASSWORD, NEKO_BIND. Conflict, unverified against tag v3.2.0.
- Port 8080 here vs chart service 10294; mux 52100 in chart vs EPR range 52000-52100 here.
- shm_size 2gb needed for browsers (compose).
