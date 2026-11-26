# storj-node context

Fetched 2026-11-26.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/storj/storj (LICENSE at v1.166.4, cmd/storagenode/cmd_setup.go at v1.166.4; releases page) | github-storj-storj.md |
| https://github.com/storj/storj/releases | github-storj-storj.md |
| https://github.com/storj/storagenode-docker (Dockerfile and docker/entrypoint at main) | github-storagenode-docker.md |
| https://docs.storj.io/node (redirects to https://storj.dev/node) | docs-storj-node.md |
| https://storj.dev/node/get-started/setup, .../install-node-software/cli and .../cli/docker | docs-storj-node.md |
| https://hub.docker.com/r/storjlabs/storagenode | dockerhub-storjlabs-storagenode.md |
| https://version.storj.io (version manifest; see notes below) | github-storj-storj.md (version info) |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/storj-node (values.yaml) | truecharts-storj-node.md |

Note: the version server manifest was read directly; it reports storagenode minimum `1.164.2` and suggested `1.166.4` (storage node and updater), other processes at `v0.0.1`, and object-mount-gui at `v26.05.3`. Its download templates point to storj/storj GitHub release assets.

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json: forgetool schema (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema (skip rule).
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base app link (skip rule).
- https://github.com/storj/storj/ (trailing slash) and https://github.com/storj/storj/ root: covered by the repo files above.
- https://github.com/storj/storagenode-docker/blob/main/Dockerfile: covered by the raw Dockerfile.
- https://github.com/storj/storj/releases/download/v${VERSION} and the `storagenode_linux_*.zip`, `identity_linux_*.zip` (amd64, arm64) URLs in draft.md and plan.md: direct archive downloads (skip rule). Asset naming recorded in github-storj-storj.md.
- https://raw.githubusercontent.com/storj/storj/v${VERSION}/LICENSE (template): covered by the v1.166.4 fetch.
- https://raw.githubusercontent.com/storj/storj/v1.166.4/LICENSE: fetched (not skipped).
- ghcr.io/trueforge-org/ubuntu (named in plan.md): image ref, not a web page (skip rule).

## Fetch failures

- https://docs.storj.io/node: 301 redirect to storj.dev; followed. Overview and sub-pages hold no node requirements, ports or commands (see docs-storj-node.md). Sub-pages `/node/get-started/identity` and `/node/get-started/install-node-software/cli/storage-node` were not fetched (budget).
- releases page: 36 assets per release, only some visible; the storagenode zips and any checksum file were not visible.

## plan.md corrections

- Section 1, "Version" row: "`1.166.4` ... the latest stable; `v1.167.1-rc` is a release candidate and must not be used" -> updated to say that `v1.167.1` (25 Nov) is now the Latest stable (its candidate was `v1.167.1-rc`), that `v1.166.4` (15 Nov) is one release behind and still the draft's version, and that the version server suggests `1.166.4` (minimum `1.164.2`). Source: github-storj-storj.md (releases page) and the version server read above.

The draft and plan.md's `VERSION` (1.166.4) and the Dockerfile/bake were not changed; the choice of version is for the maintainers.

## Checked and unchanged

- Upstream Dockerfile and entrypoint: EXPOSE 28967 and 14002, `/entrypoint`, ENV defaults, binary download from the version server, `SETUP=true` runs setup, `STORJ_CONSOLE_ADDRESS` default `0.0.0.0:14002`. Matches plan.md section 1.
- Renovate: `-rc` releases are pre-release on GitHub (releases page). Matches plan.md section 1.
- License: LICENSE at v1.166.4 is AGPL v3 text. Matches plan.md section 1 (the "or later" question stays unverified).
- setup defaults `server.address` `:28967` and `server.private-address` `127.0.0.1:7778`: matches plan.md section 7's claim.
- TrueCharts chart: runs as root, identity `/app/identity` and config `/app/config`, ports 28967 tcp/udp and 14002: matches plan.md sections 1 and 9.

## Unverified (not changed in plan.md)

- Section 1 "storagenode about 101 MB, identity about 69 MB, no LICENSE inside": zip contents not fetched.
- Section 1 "checksums: none found": the releases page shows only some of the 36 assets; left as is.
- Section 1 "AGPL-3.0-only (or later?)": LICENSE text fetched, no "or later" clause seen; left as is.
- Section 7 "setup refuses only when config.yaml exists": `IsValidSetupDir` body not fetched.
- Section 10 "nodes that fall behind get disqualified/suspended": not checked.
- Section 8 `storagenode version` runner and `v1.166.4` output: not checked.
- Section 10 `STORJ_STORAGE_PATH`: not checked.
- Storj docs requirements and docker run details: not reachable in the fetched pages (see docs-storj-node.md).
