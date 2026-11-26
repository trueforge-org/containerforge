# Context: tinymediamanager

Fetched 2026-11-26. Sources taken from draft.md and plan.md.

## Summarised sources

| Source URL | File |
| --- | --- |
| https://gitlab.com/tinyMediaManager/tinyMediaManager | gitlab-tinymediamanager.md (README raw at master returned 404; repo page used) |
| https://gitlab.com/tinyMediaManager/tinyMediaManager/-/blob/a2204fc/src/docker/Dockerfile.amd64 | gitlab-tinymediamanager-dockerfile-amd64.md |
| https://gitlab.com/tinyMediaManager/tinyMediaManager/-/raw/a2204fc/src/docker/Dockerfile.amd64 | gitlab-tinymediamanager-dockerfile-amd64.md |
| https://www.tinymediamanager.org/docs/docker | docs-tinymediamanager-docker.md |
| https://www.tinymediamanager.org/docs/start-parameters (followed from docs home) | docs-tinymediamanager-start-parameters.md |
| https://www.tinymediamanager.org/docs/installation (followed from docs home) | docs-tinymediamanager-installation.md |
| https://www.tinymediamanager.org/docs/ | docs-tinymediamanager-installation.md (docs home summary section) |
| https://www.tinymediamanager.org/download/ | docs-tinymediamanager-download.md |
| https://release.tinymediamanager.org/ | docs-tinymediamanager-download.md |
| https://hub.docker.com/r/tinymediamanager/tinymediamanager | dockerhub-tinymediamanager.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tinymediamanager | truecharts-tinymediamanager.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tinymediamanager/values.yaml | truecharts-tinymediamanager.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://archive.tinymediamanager.org/v5.3.5/tinyMediaManager-5.3.5-linux-amd64.tar.xz | Direct archive download. Pattern recorded in docs-tinymediamanager-download.md. |
| https://archive.tinymediamanager.org/v5.3.5/tinyMediaManager-5.3.5-linux-arm64.tar.xz | Direct archive download. Pattern recorded in docs-tinymediamanager-download.md. |
| https://www.tinymediamanager.org/docs/... (sha256 sidecar `<tarball>.sha256`) | Checksum file for a download; not fetched. |
| https://mediaarea.net/download/binary/libzen0/... .deb and libmediainfo0 .deb (Dockerfile build args) | Direct .deb downloads. Recorded in gitlab-tinymediamanager-dockerfile-amd64.md. |
| https://www.tinymediamanager.org/purchase/ | Linked from download page; not needed for the build. |
| https://github.com/trueforge-org/containerforge/tree/main/apps/java17, apps/ubuntu | ContainerForge `apps/<base>` links. |
| https://github.com/trueforge-org/forgetool/... (container-settings.schema.json, container-test.schema.json) | forgetool schema URL. |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link. |
| ghcr.io/trueforge-org/java17, ghcr.io/trueforge-org/ubuntu, ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:... | Image references, not web pages. |
| tinymediamanager/base-amd64:20260510065355 | Upstream base image reference (Docker image, not a web page). |
| https://www.tinymediamanager.org/docs/upgrade-v5 | Listed in the docs home navigation; not referenced by draft or plan. |
| docs/project-fireball.md, apps/kasmvnc, apps/hytale, apps/adguardhome-sync | Repo-internal files, not web sources. |

## Fetch failures and partial results

- https://gitlab.com/tinyMediaManager/tinyMediaManager/-/raw/master/README.md: HTTP 404. The alternative (repo page) was fetched and shows the default branch is `devel`. Retry of the README at `devel` was not done (one alternative used per rule).
- https://www.tinymediamanager.org/docs/: home page only; install/Java/data details came from /docs/installation and /docs/start-parameters instead.
- https://release.tinymediamanager.org/: no file listing; download links only. Checksum file names not confirmed.
- No hard 403 failures.
