# Context: nntp2nntp

Fetched 2026-11-26. Sources taken from draft.md and plan.md.

## Summarised sources

| Source URL | File |
| --- | --- |
| https://github.com/linuxserver/nntp2nntp | github-linuxserver-nntp2nntp.md |
| https://github.com/linuxserver/nntp2nntp/releases/tag/0.3 | github-linuxserver-nntp2nntp.md (asset names not loaded) |
| https://raw.githubusercontent.com/linuxserver/nntp2nntp/master/LICENSE | github-linuxserver-nntp2nntp.md |
| https://raw.githubusercontent.com/linuxserver/nntp2nntp/master/setup.py | github-linuxserver-nntp2nntp.md |
| https://raw.githubusercontent.com/linuxserver/nntp2nntp/master/nntp2nntp.py | github-linuxserver-nntp2nntp.md |
| https://github.com/linuxserver/docker-nntp2nntp/blob/e9a4fd33a54b/Dockerfile | github-linuxserver-docker-nntp2nntp.md |
| https://raw.githubusercontent.com/linuxserver/docker-nntp2nntp/e9a4fd33a54b/Dockerfile | github-linuxserver-docker-nntp2nntp.md |
| https://raw.githubusercontent.com/linuxserver/docker-nntp2nntp/master/root/defaults/nntp2nntp.conf (plan.md source) | github-linuxserver-docker-nntp2nntp.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/nntp2nntp | truecharts-nntp2nntp.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nntp2nntp/values.yaml | truecharts-nntp2nntp.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://github.com/linuxserver/nntp2nntp/archive/0.3.tar.gz (and `archive/<release>.tar.gz`) | Direct archive download. Pattern recorded in github-linuxserver-nntp2nntp.md and github-linuxserver-docker-nntp2nntp.md. |
| https://ghcr.io/linuxserver/nntp2nntp | GHCR image reference, not a web page. The chart's pinned digest is in truecharts-nntp2nntp.md. |
| https://bootstrap.pypa.io/... (get-pip.py, Python 2.7) | Referenced by the upstream Dockerfile only; not used by the plan. Not fetched. |
| ghcr.io/linuxserver/baseimage-alpine:3.15 | Upstream base image reference. |
| https://api.github.com/repos/linuxserver/nntp2nntp/tags (plan.md) | API variant of the tags list; the release page was fetched instead. |
| https://sourceforge.net/projects/nntp2nntp/ | Mentioned in the repo README as the original project. Not needed for the build. |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu, apps/python | ContainerForge `apps/<base>` links. |
| https://github.com/trueforge-org/forgetool/... (container-settings.schema.json, container-test.schema.json) | forgetool schema URL. |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link. |
| ghcr.io/trueforge-org/python:3.15.2@sha256:... | Image reference. |
| docs/project-fireball.md, apps/bazarr, apps/luanti | Repo-internal files, not web sources. |

## Fetch failures and partial results

- https://github.com/linuxserver/nntp2nntp/releases/tag/0.3: page loaded; the asset file names did not load ("2 assets"). Plan.md states no release assets.
- Repo README and license facts are from the summarised pages; no HTTP failures in this run.
- The repo page did not show a last commit date (plan.md: tagged commit e21c735).
