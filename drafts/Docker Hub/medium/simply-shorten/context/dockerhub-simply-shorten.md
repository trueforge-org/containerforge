# Docker Hub draganczukp/simply-shorten

Source URL(s) + date:
- https://hub.docker.com/v2/repositories/draganczukp/simply-shorten/
- https://hub.docker.com/v2/repositories/draganczukp/simply-shorten/tags?page_size=10
- Fetched 2026-11-27

## What it is
- name `simply-shorten`, namespace `draganczukp`, description "A dead simple URL shortener"
- last_updated 2023-11-19; registered 2020-05-23; pull_count 95253; stars 2; public
- Description states: **repository moved to GitLab** (https://gitlab.com/draganczukp/simply-shorten)
- Self-described: selfhosted URL shortener, Java backend (Spark Java), plain HTML/vanilla JS frontend, Pure CSS, links stored in SQLite, optional custom short names, simple API. Author considers it complete; no new features planned.

## Tags (Docker Hub, page_size=10, count 3)
| tag | last_updated | full_size | arch |
| --- | --- | --- | --- |
| latest | 2023-11-19 | 158572101 | amd64 |
| 1.1 | 2020-09-19 | 238998059 | amd64 |
| 1.0 | 2020-05-23 | 239065128 | amd64 |

## Install/build steps (from full_description)
- Build: `gradle build --no-daemon` (Gradle 6.x and JDK 11 stated; other versions untested)
- Docker: `docker build . -t simply-shorten:latest`
- docker-compose sample in the repo.

## Runtime / entrypoint / env
| var | purpose |
| --- | --- |
| username | basic auth user |
| password | basic auth password |
| db_url | path to SQLite file (e.g. `/urls.sqlite` in README example) |
| INSECURE_DISABLE_PASSWORD | set exactly to `I_KNOW_ITS_BAD` to disable auth |

- Port: 4567 (EXPOSE in Dockerfile)
- Volume example in docs: host file mounted to `/urls.sqlite`

## Gotchas
- Docker Hub `latest` is 2023-11-19; GitLab tags include 1.3 and 1.2 that do not appear on Docker Hub (see gitlab-simply-shorten-dockerfile.md).
- Chart uses tag `1.1` (Docker Hub, amd64 only).
