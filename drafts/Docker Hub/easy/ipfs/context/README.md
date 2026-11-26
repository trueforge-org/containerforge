# ipfs: context sources

Fetched 2026-11-26. Summaries for every web source referenced by `draft.md` and `plan.md`.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/ipfs/kubo (+ raw Dockerfile v0.43.2 and v0.43.1, bin/container_daemon, docs/environment-variables.md, README.md, LICENSE-MIT, releases/tag/v0.43.2) | github-ipfs-kubo.md |
| https://github.com/ipfs/kubo/blob/v0.43.1/Dockerfile | github-ipfs-kubo.md (raw Dockerfile v0.43.1) |
| https://hub.docker.com/r/ipfs/kubo | dockerhub-ipfs-kubo.md |
| https://docs.ipfs.tech/ | docs-ipfs-tech.md |
| https://docs.ipfs.tech/install/run-ipfs-inside-docker/ (followed from docs home; section in docs-ipfs-tech.md) | docs-ipfs-tech.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ipfs (Chart.yaml, values.yaml via raw) | truecharts-ipfs.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page, skipped by rule |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base link, skipped by rule |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema, skipped by rule |
| https://github.com/ipfs/kubo/releases/download/v${V}/kubo_v${V}_linux-${TARGETARCH}.tar.gz | templated release binary download. Pattern recorded in github-ipfs-kubo.md |
| https://github.com/ipfs/kubo/releases/download/v0.43.1/kubo_v0.43.1_linux-amd64.tar.gz, `...linux-arm64.tar.gz` | direct binary download (v0.43.1). Pattern recorded in github-ipfs-kubo.md |
| https://github.com/ipfs/kubo/releases/download/v0.43.2/kubo_v0.43.2_linux-amd64.tar.gz, `...linux-arm64.tar.gz` | direct binary download (v0.43.2). Pattern recorded in github-ipfs-kubo.md |
| http://ipfs-probe:5001/api/v0/version | test-harness hostname in plan section 11, not a web source |

Named but not summarised: `dist.ipfs.tech/kubo/v0.43.2/` (plan section 1, alternative download directory, direct binary download), `busybox:stable-glibc`, `debian:bookworm-slim`, `golang` base images (upstream build stages, not references for ContainerForge).

## Fetch failures

- https://github.com/ipfs/kubo/releases/tag/v0.43.2: the release page loaded (release date, tag, commit), but the asset list did not load ("There was an error while loading"). Asset names and `.sha512` files could not be confirmed. No retry (no 403/404).

## plan.md corrections

1. plan.md section 1, Version row. Old: "The draft and chart still say the previous patch release." New: "The draft still says v0.43.1; the TrueCharts chart already uses v0.43.2." Source: truecharts-ipfs.md (chart `appVersion: 0.43.2`, image `v0.43.2`); draft.md lines with `v0.43.1`.

Unverified (not edited):
- plan.md section 1: tarball contents (`kubo/ipfs`, `kubo/LICENSE`, `kubo/LICENSE-APACHE`, `kubo/LICENSE-MIT`, `kubo/README.md`, `kubo/build-log`, `kubo/install.sh`) and the amd64 `.sha512` check. The tarballs were not downloaded and the asset list did not load. UNVERIFIED.
- plan.md section 1 and 4: "`<asset>.sha512` files published next to each tarball." Not confirmed, see fetch failure above.
- plan.md section 1: the amd64 binary is dynamically linked against glibc. Not checked.
- plan.md section 9: "tini provided by the ubuntu base entrypoint". Not checked.
- plan.md section 7: "kubo defaults to 127.0.0.1" for the API. Not stated in fetched sources.
- plan.md section 6: `IPFS_TELEMETRY` default "" (unset). Docs say the default is `auto`. Not a contradiction for an empty env, so not edited.
- plan.md section 6: `GOLOG_LOG_LEVEL` default "". Dockerfile sets `ENV GOLOG_LOG_LEVEL=""`; docs say the default is `error`. Not edited.
- plan.md section 1: the chart's port and probe details are not in plan; the draft's `/data/ipfs` and extra PVCs are reflected in truecharts-ipfs.md.
