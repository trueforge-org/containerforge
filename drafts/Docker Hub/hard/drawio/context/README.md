# drawio context index

Fetched 2026-11-26. Summaries of every web source referenced by draft.md and plan.md.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/jgraph/drawio | github-jgraph-drawio.md |
| https://github.com/jgraph/drawio/releases/tag/v32.7.4 | github-jgraph-drawio.md (release section) |
| https://github.com/jgraph/docker-drawio/blob/d2e740b/main/Dockerfile (fetched as raw) | github-docker-drawio.md |
| raw d2e740b/main/docker-entrypoint.sh (plan's entrypoint facts) | github-docker-drawio.md (env vars, PreConfig, keystore sections) |
| https://hub.docker.com/r/jgraph/drawio | dockerhub-jgraph-drawio.md |
| https://www.drawio.com | docs-drawio-com.md |
| https://archive.apache.org/dist/tomcat/tomcat-9/ | docs-archive-apache-tomcat-9.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/drawio | truecharts-drawio.md (directory not fetched; values.yaml fetched via raw URL) |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (not a source) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/java11 | containerforge apps/<base> link |
| https://github.com/jgraph/drawio/releases/download/v32.7.4/draw.war | direct binary download (asset naming recorded in github-jgraph-drawio.md) |
| https://raw.githubusercontent.com/jgraph/drawio/.../${VERSION}... (plan template, not in draft) | not in the draft list; n/a |

## Fetch failures and partial content

- Release v32.7.4 page: "Assets 3" shown, but the asset list did not load. draw.war presence not confirmed.
- Hub page: architectures not listed; no versioned tags shown.
- Not fetched: Tomcat version directory (for `.sha512` files), LICENSE raw at v32.7.4 (plan states Apache-2.0; the repo page reports Apache-2.0 too).

## plan.md corrections

- Section 1, Version row: `releases/latest` claim for v32.7.4 marked stale. The TrueCharts chart and Docker Hub use `jgraph/drawio:32.7.7` (digest `sha256:9911eb71...`); the 32.7.4 pin was kept (maintainer decision). Source: truecharts-drawio.md, dockerhub-jgraph-drawio.md.
- Section 1, Downloads row: Tomcat "exact 9.0.x UNVERIFIED" -> newest 9.0.x on archive.apache.org is v9.0.124 (2026-11-13). Source: docs-archive-apache-tomcat-9.md.
- Section 1, Entrypoint facts row: "full list of DRAWIO_* variables is UNVERIFIED" -> full list added from the fetched entrypoint. Source: github-docker-drawio.md.

## plan.md unverified (not edited)

- Section 1, Downloads: draw.war "found in the release's expanded assets". The release page shows "Assets 3" but its list did not load in this fetch, so draw.war presence is not confirmed here. Source: github-jgraph-drawio.md.
- Section 1, Checksum: "Tomcat: `.sha512` next to each tarball on apache.org". The tomcat-9 index shows only version dirs and KEYS; a version directory was not opened. Source: docs-archive-apache-tomcat-9.md.
- Section 1, Export server row: the Docker Hub page says the jgraph project provides an export server image and compose setups, while the jgraph/drawio repo README and the Dockerfile do not mention one. The plan's "not in this image" conclusion is consistent with the Dockerfile. Source: dockerhub-jgraph-drawio.md, github-jgraph-drawio.md.
- Hub page says the image is built on `tomcat:9-jre11`; the Dockerfile uses `tomcat:9.0-jdk11-temurin`. The Dockerfile is authoritative. Source: github-docker-drawio.md.
- Section 6: `DRAWIO_CSP_HEADER`, `DRAWIO_GITLAB_ID`, `DRAWIO_GITLAB_URL` are verified; `DRAWIO_GITLAB_SECRET` and the Google/OneDrive variables are not in settings.yaml. Not an error; a possible addition. Source: github-docker-drawio.md.
