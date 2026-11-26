# docker context index

Fetched 2026-11-26. Summaries of every web source referenced by draft.md and plan.md.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/docker-library/docker/blob/70cd6b52204a3bf037510cb750e099c34b081bd4/29/dind/Dockerfile | github-docker-library-docker.md (Dockerfile, fetched via raw URL) |
| (raw) .../29/dind/dockerd-entrypoint.sh at 70cd6b5 | github-docker-library-docker.md (entrypoint section) |
| https://github.com/moby/moby | github-moby-moby.md |
| https://raw.githubusercontent.com/moby/moby/master/LICENSE | github-moby-moby.md (license section) |
| https://mobyproject.org/ | docs-mobyproject-org.md |
| https://hub.docker.com/_/docker | dockerhub-docker.md |
| https://download.docker.com/linux/static/stable/x86_64/ | download-docker-com-static-index.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/docker | truecharts-docker.md (chart directory itself not fetched; values.yaml fetched via raw URL) |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/docker/values.yaml | truecharts-docker.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (not a source) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://raw.githubusercontent.com/moby/moby/v${VERSION}/LICENSE | contains `${` (template; master LICENSE fetched instead) |
| https://download.docker.com/linux/static/stable/x86_64/docker-29.10.0.tgz | direct binary download (asset pattern recorded in download-docker-com-static-index.md) |
| https://download.docker.com/linux/static/stable/aarch64/docker-29.10.0.tgz | direct binary download (asset pattern recorded) |

## Named references not fetched

- `docker:29.10.0-dind` (draft container image): covered by the Docker Hub and TrueCharts summaries.
- `docker-rootless-extras-29.10.0.tgz`: listed in the static index summary, not downloaded.

## Fetch failures

- None. All non-skipped URLs returned content.

## plan.md corrections

- Section 1, Version row: "`docker-29.10.0.tgz` is the newest file in .../x86_64/ (... 29.9.2, 29.9.3, 29.10.0 are the last three)" -> marked stale: the listing also has `docker-29.10.1.tgz` (2026-11-24), newer than 29.10.0 (2026-11-16). The pin itself was left at 29.10.0 (maintainer decision). Source: download-docker-com-static-index.md.
- Section 1, Checksum row: "download.docker.com publishes no checksum file that I found. UNVERIFIED." -> the listing has `docker-29.10.0.tgz.sha256` (85 bytes) next to each tarball, and the upstream dind Dockerfile pins sha256 per arch (x86_64 7c1ebadc..., aarch64 6e5159e8...). Source: download-docker-com-static-index.md, github-docker-library-docker.md.

## plan.md unverified (not edited)

- Section 1, Renovate row: whether moby/moby tags are `v29.10.0`. The moby README (per the fetch summary) cites the tag format `docker-v29.0.0`, which would need a different `extractVersion`. Not confirmed against the tag list. Source: github-moby-moby.md.
- Section 7 (start.sh): `exec dockerd-rootless.sh ...`. The upstream dockerd-entrypoint.sh has no dockerd-rootless.sh; rootless mode is selected by non-zero uid and runs `rootlesskit`. Source: github-docker-library-docker.md.
- Section 4 step 2 (rootless packages `slirp4netns`, `fuse-overlayfs`, `uidmap`): rootless needs rootlesskit and slirp4netns per the entrypoint; whether the extras tarball supplies rootlesskit is not confirmed. Source: github-docker-library-docker.md.
- Draft "Security expectations": draft lists extra persistence only as `/var/lib/docker` and `/certs/client`; TrueCharts values also mount `docker-certs-ca` at `/config`. Source: truecharts-docker.md. Not a plan.md edit.
- Draft "Container" field `docker:29.10.0-dind`: the TrueCharts values use `29.10.1-dind`. Source: truecharts-docker.md. Not edited (draft is not to be changed).
