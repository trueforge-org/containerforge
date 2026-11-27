# WeKan install page (wekan.fi/install)

Source URL(s): https://wekan.fi/install (fetched 2026-11-27; text extracted from HTML)

## Versions shown on the page
- WeKan 13.35, FerretDB 1.116.0, Meteor 3.6.1, Node 26.13.1, NPM 12.2.3.

## Databases
- FerretDB v1 with SQLite is the default on every platform (bundle, Docker, Snap, Kubernetes). No DB server needed.
- FerretDB v1 with PostgreSQL works. MySQL, MariaDB, SAP HANA: experimental.
- MongoDB 6, 7, 8, 9 supported.
- MongoDB refuses to start on Linux kernels 6.19 to 7.0.13 (Ubuntu 26.04 included) until MongoDB 8.0.35 / 9.0.4 or kernel 7.0.14. FerretDB is not affected.

## Docker
- Docker platforms: amd64, arm64, s390x, ppc64le, riscv64, from Docker Hub, GitHub and Quay.io.

## Gotchas (from page)
- Only the newest WeKan release is supported. Older versions are "buggy and vulnerable".
- Snap data dir: `/var/snap/wekan/common` (not in the container).
- Page is aimed at the Snap and bundle installs; the container install steps are not on this page.
