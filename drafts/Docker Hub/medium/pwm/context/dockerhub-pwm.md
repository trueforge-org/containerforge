# Docker Hub: fjudith/pwm

Source URL(s):
- https://hub.docker.com/v2/repositories/fjudith/pwm/
- https://hub.docker.com/v2/repositories/fjudith/pwm/tags?page_size=10
Fetched: 2026-11-27

## Repository
| Key | Value |
| --- | --- |
| description | Dockerized PWM based on Tomcat:8-jre8 official image with SSL enabled. (stale; README says Tomcat 8) |
| pull_count | 1892617 |
| star_count | 17 |
| last_updated | 2023-04-11 |
| is_automated | true |
| tag count | 18 |

## Tags (page_size=10)
| Tag | Arch | Last pushed |
| --- | --- | --- |
| alpine (index, digest e56613b8...) | multi-arch index; amd64 digest matches chart pin | 2023-04-11 |
| debian (index) | multi-arch | 2023-04-11 |
| 2.0.5-alpine, 2.0.5-debian | | 2023-04 |
| 316b2705-alpine/-debian, a011fb61-alpine/-debian, cc7f12e8-alpine/-debian | commit-hash tags | 2023-04 |

No semver tag beyond 2.0.5 is listed on Docker Hub (tag count 18).

## Run (README in full_description)
- `docker run --rm -it --name=pwm -p 8080:8080 fjudith/pwm`
- Web UI at http://<host>:8080 (allow start-up time; DB population on first run is slow).
- Persistent volume: `/usr/share/pwm` (PWM configuration).
- Database: LDAP schema by default; image supports linking to mongodb, mysql or postgres.

## Gotchas
- README version text (1.9.1) is stale versus the 2.0.5 tag and upstream 2.0.8 (see github-pwm-release.md).
- Docker Hub description says Tomcat 8 base; the alpine Dockerfile uses tomcat:9-jre8-alpine.
