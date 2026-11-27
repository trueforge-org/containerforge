# GitHub: semaphoreui/semaphore (Dockerfile and server-wrapper at 7cf38e0; latest release)

Source URL(s): raw deployment/docker/server/Dockerfile and server-wrapper at 7cf38e07fa33532defa12db82b847b2ee4e6ea6f (raw used after api rate limit); api repos/semaphoreui/semaphore/license; api releases/latest; api releases/tags/v2.20.24 (fetched 2026-11-27)

## Releases
- Latest GitHub release: `v2.20.23`, published 2026-11-10T08:04:07Z. Assets: `semaphore_2.20.23_checksums.txt` (+ .sig), `semaphore_2.20.23_linux_{386,amd64,arm64,...}.tar.gz`, `.deb`, `.rpm`, CycloneDX `.cdx.json` per platform.
- `releases/tags/v2.20.24`: Not Found (no GitHub release for v2.20.24; Docker Hub only).
- License: MIT (GitHub SPDX).

## Upstream Dockerfile (7cf38e0)
- Builder: `FROM --platform=$BUILDPLATFORM golang:1.26-alpine3.24`. apk libc-dev curl nodejs npm git gcc zip unzip tar; installs taskfile; `task deps:image` and `task build`; optional private pro module via gh_token secret when APP_BUILD_TYPE set.
- Tools: OpenTofu 1.11.0 (github release tofu_<ver>_linux_<arch>.tar.gz), Terraform 1.11.3 (releases.hashicorp.com zip), Terragrunt 0.78.0 (github binary). Downloads have no checksum check in the Dockerfile.
- Runtime: `FROM alpine:3.24`; ARG ANSIBLE_VERSION=13.5.0; ANSIBLE_VENV_PATH=/opt/semaphore/apps/ansible/${ANSIBLE_VERSION}/venv.
- apk: bash curl git gnupg mysql-client openssh-client-default python3 py3-pip rsync sshpass tar tini tzdata unzip wget zip jq.
- `adduser -D -u 1001 -G root semaphore`; mkdir/chown 1001:0 for /tmp/semaphore, /etc/semaphore, /var/lib/semaphore, /opt/semaphore.
- ssh config StrictHostKeyChecking no / UserKnownHostsFile /dev/null.
- COPY server-wrapper to /usr/local/bin, semaphore binary to /usr/local/bin, tofu, terraform, terragrunt.
- ENV VIRTUAL_ENV and PATH for ansible venv.
- `WORKDIR /home/semaphore`; `USER 1001`; `EXPOSE 3000`; `ENTRYPOINT ["/sbin/tini", "--"]`; `CMD ["/usr/local/bin/server-wrapper"]`.

## server-wrapper (7cf38e0, raw)
- Shell script. `file_env` helper: reads `<VAR>_FILE` into `<VAR>` (error if both set).
- Ends with `exec /usr/local/bin/semaphore` (after setup).
- Env names read: SEMAPHORE_CONFIG_PATH (default /etc/semaphore), SEMAPHORE_DB_PATH (default /var/lib/semaphore), SEMAPHORE_DB_DIALECT (sqlite/mysql/postgres), SEMAPHORE_DB_HOST, SEMAPHORE_DB_PORT, SEMAPHORE_DB, SEMAPHORE_DB_USER, SEMAPHORE_DB_PASS, SEMAPHORE_DB_DIALECT_ID, SEMAPHORE_ACCESS_KEY_ENCRYPTION, SEMAPHORE_ADMIN, SEMAPHORE_ADMIN_NAME, SEMAPHORE_ADMIN_EMAIL, SEMAPHORE_ADMIN_PASSWORD, SEMAPHORE_FIRST_RUN, SEMAPHORE_TMP_PATH, SEMAPHORE_WEB_ROOT, SEMAPHORE_MIGRATE_FROM_BOLTDB, SEMAPHORE_MIGRATE_SKIP_TASK_OUTPUT, SEMAPHORE_IMPORT_PROJECT_FILE, SEMAPHORE_IMPORT_PROJECT_NAME, SEMAPHORE_LDAP_* (ACTIVATED, HOST, PORT, NEEDTLS, DN_BIND, PASSWORD, DN_SEARCH, SEARCH_FILTER, MAPPING_*).

## Ports
- 3000/tcp.

## Volumes/paths
- `/etc/semaphore` (config), `/var/lib/semaphore` (sqlite DB default), `/tmp/semaphore`, `/opt/semaphore` (ansible venv), `/home/semaphore` (WORKDIR).

## User/UID
- semaphore uid 1001, group root (gid 0).

## Runtime deps
- tini, python3 + ansible venv (ansible 13.5.0), openssh client, git, mysql-client; external DB optional (sqlite default).

## Gotchas
- API rate-limited once; raw.githubusercontent.com used for the Dockerfile and wrapper.
- Upstream Dockerfile downloads tofu/terraform/terragrunt without checksum verification.
