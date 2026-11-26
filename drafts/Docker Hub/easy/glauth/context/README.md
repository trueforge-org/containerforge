# Context index: glauth

Fetched 2026-11-26.

## Sources summarised

| Source URL | Summary file |
| --- | --- |
| https://github.com/glauth/glauth | github-glauth-glauth.md |
| https://raw.githubusercontent.com/glauth/glauth/251ec3ef667e7e51f4b38c3f52c048f7f20dfc32/v2/docker/Dockerfile-standalone | github-glauth-glauth.md |
| https://raw.githubusercontent.com/glauth/glauth/251ec3ef667e7e51f4b38c3f52c048f7f20dfc32/v2/docker/assets/start-standalone.sh | github-glauth-glauth.md |
| https://raw.githubusercontent.com/glauth/glauth/251ec3ef667e7e51f4b38c3f52c048f7f20dfc32/v2/docker/assets/default-config-standalone.cfg | github-glauth-glauth.md |
| https://github.com/glauth/glauth/releases/tag/GLAuth-v2.5.5 | github-glauth-glauth.md (asset list did not load) |
| https://raw.githubusercontent.com/glauth/glauth/GLAuth-v2.5.5/LICENSE | github-glauth-glauth.md |
| https://hub.docker.com/r/glauth/glauth | dockerhub-glauth-glauth.md |
| https://glauth.github.io/ | docs-glauth-github-io.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/glauth/values.yaml | truecharts-glauth.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page (only the user can sign) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge apps/<base> link (not in glauth draft; kept for completeness, no fetch) |
| https://github.com/glauth/glauth/releases/download/GLAuth-v2.5.4/glauth-linux-amd64 | direct binary download (draft, outdated tag); pattern `glauth-linux-<arch>` recorded |
| https://github.com/glauth/glauth/releases/download/GLAuth-v2.5.4/glauth-linux-arm64 | direct binary download (draft, outdated tag) |
| https://github.com/glauth/glauth/releases/download/GLAuth-v2.5.5/glauth-linux-amd64 | direct binary download (plan.md); pattern recorded |
| https://github.com/glauth/glauth/releases/download/GLAuth-v2.5.5/glauth-linux-arm64 | direct binary download (plan.md); pattern recorded |
| https://github.com/glauth/glauth/blob/251ec3ef.../v2/docker/Dockerfile-standalone (blob form) | same file as the raw Dockerfile URL, fetched once |
| https://gcr.io/distroless/base-debian13 | base image reference, not a page fetched |
| ghcr.io/trueforge-org/ubuntu | ghcr image ref, not a web page |
| https://glauth.github.io/ docs/ sub-pages | not followed (budget); the sample config was read instead |

## Fetch failures

- https://raw.githubusercontent.com/glauth/glauth/251ec3ef.../v2/docker/start-standalone.sh: HTTP 404. Retried at `v2/docker/assets/start-standalone.sh` (the Dockerfile COPY source path), which succeeded.
- https://raw.githubusercontent.com/glauth/glauth/251ec3ef.../v2/docker/default-config-standalone.cfg: HTTP 404. Retried at `v2/docker/assets/default-config-standalone.cfg`, which succeeded.
- https://github.com/glauth/glauth/releases/tag/GLAuth-v2.5.5: page loaded but the asset list did not (error placeholder). Asset names and digests from plan.md could not be re-checked.

## plan.md corrections

None made. Nothing in the sources contradicted a fact that plan.md states (ports, sample config, entrypoint, start script, license, tag, EXPOSE all match).

Unverified (not edited):
- plan.md section 1: release asset SHA-256 digests (amd64 `b0a27c...`, arm64 `d0a17a...`). The release asset list did not load.
- plan.md section 1: binary statically linked. Not checked.
- plan.md section 1: "Env vars: none documented". The Docker Hub page documents `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for S3-hosted config. Not a plan error; noted.
- plan.md section 10: `--check-config` flag and the zero-user start behaviour. Not checked.
- plan.md section 8: `http` probe on 5555 path. Not checked.
