# Context: h5ai

Fetched 2026-11-26. Sources taken from draft.md and plan.md.

## Summarised sources

| Source URL | File |
| --- | --- |
| https://github.com/lrsjng/h5ai | github-lrsjng-h5ai.md |
| https://raw.githubusercontent.com/lrsjng/h5ai/master/README.md | github-lrsjng-h5ai.md |
| https://github.com/lrsjng/h5ai/releases | github-lrsjng-h5ai.md (partial, see failures) |
| https://larsjung.de/h5ai/ | github-lrsjng-h5ai.md (307 redirect to https://github.com/lrsjng/h5ai/, recorded there) |
| https://github.com/awesometic/docker-h5ai/blob/master/Dockerfile | github-awesometic-docker-h5ai.md |
| https://raw.githubusercontent.com/awesometic/docker-h5ai/master/Dockerfile | github-awesometic-docker-h5ai.md |
| https://hub.docker.com/r/awesometic/h5ai | dockerhub-awesometic-h5ai.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/h5ai | truecharts-h5ai.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/h5ai/values.yaml | truecharts-h5ai.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://github.com/lrsjng/h5ai/releases/download/v0.30.0/h5ai-0.30.0.zip | Direct binary download. Asset pattern recorded in github-lrsjng-h5ai.md. |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | ContainerForge `apps/<base>` link. |
| https://github.com/trueforge-org/containerforge/tree/main/apps/nginx | ContainerForge `apps/<base>` link. |
| https://github.com/trueforge-org/forgetool/... (container-settings.schema.json, container-test.schema.json) | forgetool schema URL. |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link. |
| ghcr.io/trueforge-org/ubuntu, ghcr.io/trueforge-org/nginx:1.28.3@sha256:... | Image references, not web pages. |
| docker.io/awesometic/h5ai:latest | Image reference; the Docker Hub page above is summarised. |
| https://release.larsjung.de/h5ai/ | Not referenced by the draft or plan (only mentioned inside the README summary). |
| docs/project-fireball.md, apps/it-tools, apps/bookstack, apps/kasmvnc | Repo-internal files, not web sources. |

## Fetch failures and partial results

- https://github.com/lrsjng/h5ai/releases: the page loaded the v0.30.0 tag and metadata; the asset list did not load. Asset name `h5ai-0.30.0.zip` comes from plan.md's verification, not this fetch.
- https://larsjung.de/h5ai/: 307 redirect to https://github.com/lrsjng/h5ai/ (not followed as a separate fetch; the README fetch covers the same repo).
- Not fetched: the awesometic `init.sh`, `supervisord.conf` and `h5ai.conf` (only referenced in the Dockerfile).
