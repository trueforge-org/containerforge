# Docker Hub friendica (official image)

Source URL(s) + fetch date:
- https://hub.docker.com/_/friendica (2026-11-26, WebFetch summary)

What it is: Docker Official Image for Friendica, 5M+ pulls.

Tags: stable 2026.05 `apache`, `fpm`, `fpm-alpine` (and `stable-` variants); `latest`/`stable` point to apache. RC 2026.08 (`rc`, `rc-apache`, `rc-fpm`, `rc-fpm-alpine`). Dev 2026.11 (`dev`, `dev-apache`, `dev-fpm`, `dev-fpm-alpine`).

Architectures: amd64, arm32v5, arm32v6, arm32v7, arm64v8, i386, ppc64le, riscv64, s390x.

Ports: apache 80 (quick start `-p 8080:80`); fpm 9000 (do not publish).

Volumes: `/var/www/html` (install and data), `/var/lib/mysql` (database container).

Env and database: see the docker README in `github-friendica-docker.md` (same variables). MariaDB/MySQL needed; use the DB container's name as MYSQL_HOST.

Image size: latest about 295.2 MB (page text). Maintainer nupplaPhil, issues at github.com/friendica/docker/issues.

Failed to fetch: none.
