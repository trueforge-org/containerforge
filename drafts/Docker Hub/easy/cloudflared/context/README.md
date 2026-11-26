# context: cloudflared

## Sources (URL -> file)
| Source URL | File | Fetched |
| --- | --- | --- |
| https://github.com/cloudflare/cloudflared (README via raw master) | github-cloudflare-cloudflared.md | 2026-11-26 |
| https://github.com/cloudflare/cloudflared/releases/latest (release, assets, checksums) | github-cloudflare-cloudflared.md | 2026-11-26 |
| https://github.com/cloudflare/cloudflared/blob/518d7f7969b764df628bb4b1088f0f154901dc4e/Dockerfile | github-cloudflare-cloudflared-dockerfile.md | 2026-11-26 |
| https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/ | docs-cloudflare-cloudflare-tunnel.md | 2026-11-26 |
| https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/configure-tunnels/cloudflared-parameters/run-parameters/ (not linked in draft; followed) | docs-cloudflare-cloudflared-run-parameters.md | 2026-11-26 |
| https://hub.docker.com/r/cloudflare/cloudflared | dockerhub-cloudflare-cloudflared.md | 2026-11-26 |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cloudflared (read via raw values.yaml) | truecharts-cloudflared.md | 2026-11-26 |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/... (both schema URLs): forgetool schema.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base app link.
- https://github.com/cloudflare/cloudflared/releases/download/2026.11.1/cloudflared-amd64.pkg and .../cloudflared-arm64.pkg: direct binary download (macOS .pkg). Asset naming recorded in github-cloudflare-cloudflared.md.
- https://github.com/cloudflare/cloudflared/releases/download/${VERSION}/cloudflared-linux-${TARGETARCH}, .../2026.11.2/cloudflared-linux-amd64, .../cloudflared-linux-arm64: direct binary downloads. Naming recorded.
- https://github.com/cloudflare/cloudflared/releases/tag/${VERSION}: URL template with variable.
- https://raw.githubusercontent.com/cloudflare/cloudflared/${VERSION}/LICENSE: template with variable; not fetched.
- https://hub.docker.com/r/cloudflare/cloudflared also appears as copy-from; covered by dockerhub file.

## Fetch failures
- None.

## plan.md corrections
- None made. Context confirms plan.md's version (2026.11.2), asset names, checksums, Dockerfile facts, and env var defaults.
- Unverified (left as-is): plan.md section 1 metrics defaults (non-container `127.0.0.1` on ports 20241-20245, container `0.0.0.0:<PORT>/metrics`). The run-parameters page points to a separate metrics page, which was not fetched. Also unverified: plan.md's claim that the release binary (not built with `CONTAINER_BUILD`) binds `127.0.0.1`.
- Note for the draft (not edited): TrueCharts chart already pins 2026.11.2; draft.md's `.pkg` links are macOS installers.
