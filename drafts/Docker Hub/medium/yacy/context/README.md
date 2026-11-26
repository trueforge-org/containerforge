# Context: yacy

Fetched 2026-11-26. Sources taken from draft.md and plan.md.

## Summarised sources

| Source URL | File |
| --- | --- |
| https://github.com/yacy/yacy_search_server | github-yacy-yacy-search-server.md |
| https://raw.githubusercontent.com/yacy/yacy_search_server/eba3f94b4376180de5fbf3812c41e3c65dad4cfb/startYACY.sh (followed from Dockerfile/plan) | github-yacy-yacy-search-server.md |
| https://raw.githubusercontent.com/yacy/yacy_search_server/eba3f94b4376180de5fbf3812c41e3c65dad4cfb/defaults/yacy.init (followed) | github-yacy-yacy-search-server.md |
| https://github.com/yacy/yacy_search_server/blob/eba3f94b4376180de5fbf3812c41e3c65dad4cfb/docker/Dockerfile | github-yacy-docker-dockerfile.md |
| https://raw.githubusercontent.com/yacy/yacy_search_server/eba3f94b4376180de5fbf3812c41e3c65dad4cfb/docker/Dockerfile | github-yacy-docker-dockerfile.md |
| https://download.yacy.net/ | docs-download-yacy-net.md |
| https://yacy.net/download_installation/ | docs-yacy-net-download-installation.md |
| https://yacy.net/docs/ | docs-yacy-net-home.md |
| https://yacy.net/ | docs-yacy-net-home.md |
| https://hub.docker.com/r/yacy/yacy_search_server | dockerhub-yacy-yacy-search-server.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/yacy | truecharts-yacy.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/yacy/values.yaml | truecharts-yacy.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://download.yacy.net/yacy_v1.942_202608150808_f9c4b9700.tar.gz | Direct binary/archive download. Naming pattern and listing recorded in docs-download-yacy-net.md. |
| http://download.yacy.net/... (any .exe, .dmg, .sig) | Not used by the build. |
| https://github.com/trueforge-org/containerforge/tree/main/apps/java25, apps/java21, apps/ubuntu | ContainerForge `apps/<base>` links. |
| https://github.com/trueforge-org/forgetool/... (container-settings.schema.json, container-test.schema.json) | forgetool schema URL. |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link. |
| ghcr.io/trueforge-org/java25:25.0.1@sha256:..., ghcr.io/trueforge-org/java21:21.0.8@sha256:... | Image references, not web pages. |
| eclipse-temurin:24-jdk-noble | Upstream base image reference. |
| yacy/yacy_search_server:latest, docker.io/yacy/yacy_search_server | Image references; the Docker Hub page is summarised. |
| https://yacy.net/faq/, /demonstration_tutorial_screenshot/, https://yacy.searchlab.eu/Status.html, https://community.searchlab.eu, https://yacystats.de, youtube tutorials | Not needed for the container build (linked from yacy.net home). |
| https://release.yacy.net (developer build) | Mentioned in the GitHub README summary; not used. |
| docs/project-fireball.md, apps/nzbhydra2, apps/airsonic-advanced, apps/fenrus, apps/java25 | Repo-internal files, not web sources. |

## Fetch failures

- https://raw.githubusercontent.com/yacy/yacy_search_server/eba3f94b4376180de5fbf3812c41e3c65dad4cfb/LICENSE: HTTP 404. Alternative (GitHub blob URL at the same commit): also HTTP 404. The license was not read from the file; the repo page and yacy.net give GPL-2.0-or-later with some LGPL parts.
- https://raw.githubusercontent.com/yacy/yacy_search_server/eba3f94b4376180de5fbf3812c41e3c65dad4cfb/docker/Readme.md: HTTP 404 (the Docker Hub page points to it). Alternative not tried (the Docker Hub and download pages cover the same Docker facts).
- https://yacy.net/docs/: overview only; supported Java version, default ports and discovery requirements are on sub-pages not fetched.
- https://download.yacy.net/: no checksum files exist in the listing (not a failure, a finding).
