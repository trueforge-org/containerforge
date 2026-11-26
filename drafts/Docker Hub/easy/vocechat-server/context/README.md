# Context sources: vocechat-server

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/Privoce/vocechat-server-rust | github-privoce-vocechat-server-rust.md |
| https://raw.githubusercontent.com/Privoce/vocechat-server-rust/master/README.md | github-privoce-vocechat-server-rust.md (README; main returned 404) |
| https://github.com/Privoce/vocechat-server-rust/blob/96c0aa5d100cc1c9090c004dbeb662ba3a08a6cd/build/docker/Dockerfile | github-privoce-vocechat-server-rust.md (raw Dockerfile at 96c0aa5) |
| https://github.com/Privoce/vocechat-server-rust/releases/download/v0.5.41/... (see skipped) | github-privoce-vocechat-server-rust.md (release page) |
| https://github.com/Privoce/vocechat-server-rust/releases/tag/v0.5.41 | github-privoce-vocechat-server-rust.md (release page; assets not loaded) |
| https://doc.voce.chat/ | docs-voce-chat.md |
| https://voce.chat/ | docs-voce-chat.md |
| https://voce.chat/install/docker | docs-voce-chat.md (404, see failures) |
| https://hub.docker.com/r/privoce/vocechat-server | dockerhub-privoce-vocechat-server.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/vocechat-server | truecharts-vocechat-server.md |
| https://sh.voce.chat/web_client/v0.4.x | README.md (see failures; not summarised) |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/Privoce/vocechat-server-rust/releases/download/v${VERSION#v}/vocechat-server-v${VERSION#v}-${A}-unknown-linux-musl.zip | placeholder download URL |
| https://github.com/Privoce/vocechat-server-rust/releases/download/v0.5.41/vocechat-server-v0.5.41-{aarch64,x86_64}-unknown-linux-musl.zip | direct archive download; naming recorded in the release summary |
| ghcr.io/trueforge-org/ubuntu (with digest) | ghcr image ref, not a web page |
| docker.io/privoce/vocechat-server:v0.5.41 | image ref, covered by the Docker Hub page |

## Fetch failures

- https://raw.githubusercontent.com/Privoce/vocechat-server-rust/main/README.md: HTTP 404. Alternative `master` used and succeeded.
- https://voce.chat/install/docker: HTTP 404 (docker install page). No raw alternative exists; recorded as failed.
- https://sh.voce.chat/web_client/v0.4.x: HTTP 404. Web client URL (runtime fetch per plan.md) is unavailable; its contents are unverified.
- Release assets list on https://github.com/Privoce/vocechat-server-rust/releases/tag/v0.5.41 did not load: asset names, sizes, sha256 digests and LICENSE/checksum presence unverified.

## plan.md corrections

Edited: none.

Notes (not edited, from context):
- contradiction: plan.md section 6 and section 7 use `--network.domain` as the CLI override. The TrueCharts chart uses `--network.frontend_url` and does not use `--network.domain`. plan.md also says the docker docs show `--network.domain`, which the docs pages fetched did not confirm. Unverified: whether `--network.domain` exists. Not edited.
- unverified: plan.md section 5 asset SHA256 digests (`a5ec5106...` for amd64, `04f51c96...` for arm64). The release asset list did not load, so these were not checked.
- unverified: plan.md section 1 license claims that "the repo has no LICENSE file". The README gives license names (Big Time Public License, CC BY-NC 4.0 for the Docker image, GPLv3 for clients and docs), which is consistent with plan.md's LicenseRef claim but does not confirm the absence of a LICENSE file.
- confirmed: upstream Dockerfile (busybox, EXPOSE 3000, WORKDIR, ENTRYPOINT docker-entrypoint.sh).
- confirmed: Docker Hub image is "Non-commercial"; server "Big Time Public License"; 20-user / $49 per version terms.
- note: Docker Hub run example mounts `/home/vocechat-server/data`, which is different from the plan's `/config/data`. Not an error; plan.md remaps by design.
