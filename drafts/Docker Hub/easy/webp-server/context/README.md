# Context sources: webp-server

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/webp-sh/webp_server_go | github-webp-sh-webp-server-go.md |
| https://github.com/webp-sh/webp_server_go/blob/5efe1bf88814f86588d4c0f030a12d071d7471ae/Dockerfile | github-webp-sh-webp-server-go.md (raw Dockerfile at 5efe1bf) |
| https://github.com/webp-sh/webp_server_go/releases/tag/0.16.2 | github-webp-sh-webp-server-go.md (release notes; asset list did not load) |
| https://raw.githubusercontent.com/webp-sh/webp_server_go/master/README.md | github-webp-sh-webp-server-go.md (README) |
| https://raw.githubusercontent.com/webp-sh/webp_server_go/0.16.2/config.json | github-webp-sh-webp-server-go.md (config keys) |
| https://docs.webp.sh/ | docs-webp-sh.md |
| https://docs.webp.sh/usage/ | not fetched; plan.md says 404 |
| https://hub.docker.com/r/webpsh/webps | dockerhub-webpsh-webps.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/webp-server | truecharts-webp-server.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/webp-sh/webp_server_go/releases/download/${VERSION}/webp-server-linux-${TARGETARCH} | placeholder binary download |
| https://github.com/webp-sh/webp_server_go/releases/download/0.16.2/webp-server-linux-amd64, .../webp-server-linux-arm64 | direct binary downloads; names recorded in the release summary |
| https://raw.githubusercontent.com/webp-sh/webp_server_go/${VERSION}/LICENSE | placeholder version URL (plan.md wants the LICENSE at the tag; not fetched) |
| ghcr.io/trueforge-org/ubuntu (with digest) | ghcr image ref, not a web page |
| docker.io/webpsh/webps:latest | image ref, covered by the Docker Hub page |

## Fetch failures

- https://github.com/webp-sh/webp_server_go/releases/tag/0.16.2: asset list did not load (names, sizes and checksum files unverified).
- https://docs.webp.sh/usage/ (plan.md): 404 per plan.md, not retried.

## plan.md corrections

Edited: none.

Notes (not edited):
- contradiction: plan.md section 1 lists `METADATA_PATH` as a config key and section 7 puts `"METADATA_PATH": "/tmp/metadata"` in `defaults/config.json`. The fetched 0.16.2 config.json has no `METADATA_PATH` key (the compose example mounts `/opt/metadata`). Unverified whether the binary reads it; plan.md section 1 already flags it as a struct tag. Not edited.
- confirmed: upstream Dockerfile (golang:1.27-trixie builder with libvips-dev; debian:trixie-slim runtime with libvips, libjemalloc2, libtcmalloc-minimal4, libheif AOM plugins; `CMD ["/usr/bin/webp-server","--config","/etc/config.json"]`; `VOLUME /opt/exhaust`).
- confirmed: config.json defaults (HOST 127.0.0.1, PORT 3333, IMG_PATH ./pics, EXHAUST_PATH ./exhaust, QUALITY 80, CACHE_TTL 259200).
- confirmed: latest release 0.16.2 (commit 5efe1bf, notes on x/image and ImageMap).
- unverified: release asset list and any checksum files (page did not load); plan.md section 1 `UNVERIFIED` on checksums remains.
- unverified: plan.md section 1 license "only" vs "or later" (README says GPLv3 only, no version detail).
- note: Docker compose in the docs uses `webpsh/webp-server-go`; the draft uses `webpsh/webps`. Not a plan.md error (plan.md uses the draft image), flagged for the PR.
- note: chart keys ENABLE_AVIF and ALLOWED_TYPES are not in the 0.16.2 config.json; plan.md section 6 `WEBP_ALLOWED_TYPES` default kept.
