# Context: metabase

Fetched 2026-11-26. Sources taken from draft.md and plan.md.

## Summarised sources

| Source URL | File |
| --- | --- |
| https://github.com/metabase/metabase | github-metabase-metabase.md |
| https://github.com/metabase/metabase/releases/tag/v0.65.6 | github-metabase-metabase.md |
| https://raw.githubusercontent.com/metabase/metabase/v0.65.6/LICENSE.txt | github-metabase-metabase.md |
| https://raw.githubusercontent.com/metabase/metabase/v0.65.6/LICENSE-AGPL.txt | github-metabase-metabase.md |
| https://github.com/metabase/metabase/blob/v0.65.6/bin/docker/Dockerfile | github-metabase-dockerfile.md |
| https://raw.githubusercontent.com/metabase/metabase/v0.65.6/bin/docker/Dockerfile | github-metabase-dockerfile.md |
| https://raw.githubusercontent.com/metabase/metabase/v0.65.6/bin/docker/run_metabase.sh | github-metabase-dockerfile.md (followed from Dockerfile ENTRYPOINT) |
| https://www.metabase.com/docs/latest/ | docs-metabase-home.md |
| https://www.metabase.com | docs-metabase-home.md |
| https://www.metabase.com/docs/latest/installation-and-operation/running-metabase-on-docker | docs-metabase-running-on-docker.md (named reference "Metabase Docker docs" in plan.md; no URL in draft) |
| https://hub.docker.com/r/metabase/metabase | dockerhub-metabase-metabase.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/metabase | truecharts-metabase.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/metabase/values.yaml | truecharts-metabase.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://downloads.metabase.com/v0.65.6/metabase.jar | Direct binary download (about 714 MB). Pattern recorded in github-metabase-metabase.md. |
| https://downloads.metabase.com/enterprise/v1.65.6.x/metabase.jar | Enterprise binary download, not used. |
| https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem | Certificate download referenced by the upstream Dockerfile. Not fetched; behaviour recorded (optional RDS CA). |
| https://www.metabase.com/license (footer link) | Not referenced by draft or plan. |
| https://www.metabase.com/docs/latest/... (Databases, Upgrading, etc.) | Other doc pages not needed for the build. |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu, apps/java25, apps/postgresql | ContainerForge `apps/<base>` links. |
| https://github.com/trueforge-org/forgetool/... (container-settings.schema.json, container-test.schema.json) | forgetool schema URL. |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link. |
| ghcr.io/trueforge-org/java25:25.0.1@sha256:... | Image reference, not a web page. |
| docker.io/metabase/metabase:v0.65.6 | Image reference; the Docker Hub page above is summarised. |
| eclipse-temurin:25-jre-alpine | Upstream base image reference (Dockerfile FROM). |
| docs/project-fireball.md, apps/airsonic-advanced, apps/fenrus, apps/adguardhome-sync | Repo-internal files, not web sources. |

## Fetch failures and partial results

- https://github.com/metabase/metabase/releases/tag/v0.65.6: page loaded; asset file names did not load ("Assets 2"). The jar URL is taken from release notes and plan.md, not from attached assets.
- https://www.metabase.com/docs/latest/ and https://www.metabase.com: summaries only; no Java version or health endpoint stated on either.
- No hard 403 or 404 failures.
