# restic-rest-server context index

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File | Notes |
| --- | --- | --- |
| https://github.com/restic/rest-server | github-restic-rest-server.md | repo; README via raw master |
| https://raw.githubusercontent.com/restic/rest-server/master/README.md | github-restic-rest-server.md | fetched |
| https://github.com/restic/rest-server/blob/master/Dockerfile | github-restic-rest-server.md | fetched via raw master |
| https://github.com/restic/rest-server/blob/v0.14.0/Dockerfile | github-restic-rest-server.md | fetched via raw v0.14.0 |
| https://github.com/restic/rest-server/releases/tag/v0.15.0 | github-restic-rest-server.md | fetched; asset names did not render |
| https://hub.docker.com/r/restic/rest-server | dockerhub-restic-rest-server.md | fetched |
| https://restic.readthedocs.io/ | docs-restic-readthedocs-index.md | fetched; table of contents only |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/restic-rest-server | truecharts-restic-rest-server.md | tree page; values via raw |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/restic-rest-server/values.yaml | truecharts-restic-rest-server.md | fetched |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps base link |
| http://host:8000/ | placeholder host, not a web source |
| https://github.com/restic/rest-server/releases/download/v${VERSION#v} | contains ${; direct download |
| https://github.com/restic/rest-server/releases/download/v0.14.0/rest-server_0.14.0_dragonfly_amd64.tar.gz | direct archive download; wrong OS for Linux |
| https://github.com/restic/rest-server/releases/download/v0.14.0/rest-server_0.14.0_linux_arm64.tar.gz | direct archive download; pattern recorded |
| https://github.com/restic/rest-server/releases/download/v0.15.0/rest-server_0.15.0_linux_amd64.tar.gz | direct archive download; pattern recorded |
| https://github.com/restic/rest-server/releases/download/v0.15.0/rest-server_0.15.0_linux_arm64.tar.gz | direct archive download; pattern recorded |
| https://github.com/restic/rest-server/releases/download/v0.15.0/SHA256SUMS | direct download; pattern recorded |

## Fetch failures

- None. Release asset list did not render (page loaded). restic.readthedocs.io returned only its table of contents (recorded in docs-restic-readthedocs-index.md).

## plan.md corrections

No edits made. Context agrees with plan.md on: latest release v0.15.0 (23 Nov), draft's dragonfly_amd64 link being wrong, port 8000, flags list, env names (DATA_DIRECTORY, PASSWORD_FILE, OPTIONS, DISABLE_AUTHENTICATION), `/data` volume, Go 1.26 build requirement, Docker image digest 0.15.0 in TrueCharts.

Unverified items (not edited):
- plan.md section 1 gives `docker/entrypoint.sh` behaviour and the arm64 tarball contents. Entrypoint and arm64 tarball not fetched.
- plan.md section 1 gives the amd64 and arm64 sha256 values and the SHA256SUMS contents. Not checked.
- plan.md section 1 gives license BSD-2-Clause. README says BSD 2-Clause; consistent.
- Context adds a fact not in plan.md: `/healthz` endpoint (HTTP 204, v0.15.0 changelog #259). Plan.md does not mention a healthcheck. Not a correction; noted for the app author.
