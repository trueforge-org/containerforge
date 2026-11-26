# context/ for traggo

Fetched 2026-11-26.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/traggo/server (Dockerfile @6321119, README, releases/tag/v0.8.3, config/config.go @v0.8.3) | github-traggo-server.md |
| https://traggo.net/install/ | docs-traggo-net-install.md (section "Install") |
| https://traggo.net/config/ | docs-traggo-net-install.md (section "Configuration") |
| https://traggo.net/ | docs-traggo-net-install.md (section "Home") |
| https://hub.docker.com/r/traggo/server | dockerhub-traggo-server.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/traggo (values.yaml) | truecharts-traggo.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page, not a source.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json and https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json: forgetool schema URLs.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base link.
- https://traggo.net/dev/setup/: developer setup, not relevant to install/config (not followed).
- https://github.com/traggo/server/releases/download/v${VERSION}/traggo_${VERSION}_linux_${TARGETARCH}.tar.gz, `.../traggo_0.8.3_linux_amd64.tar.gz`, `.../traggo_0.8.3_linux_arm64.tar.gz`: direct archive downloads (pattern recorded in the GitHub summary).
- https://github.com/traggo/server/blob/6321119c3c2d55f04e2e4967f6492aabd6067b76/docker/Dockerfile: fetched raw instead.
- `http://<container-ip` (draft URL with placeholder): contains a placeholder address, skipped.
- Local reference `docs/project-fireball.md` is not a web source.

## Fetch failures

- Release v0.8.3 asset list: did not load (fetch error). Names, count, and checksum presence unconfirmed.
- traggo.net is also the source for the Docker example; no other failures.
- The GitHub README contains no install or config content (fetched; recorded in the GitHub file).

## plan.md corrections

None made. Items left as unverified (not edited):
- Plan section 1: tarball contents (`traggo`, `LICENSE`, `README.md`, `.env.sample`) "verified by listing the amd64 archive". Not reproducible from this fetch.
- Plan section 1: "only 4 archives" and no checksum asset. The release shows "Assets 6" with no list. Could be four uploads plus two auto source archives. Unverified.
- Plan section 1: `TRAGGO_DATABASE_DIALECT` "sqlite3, the only valid value". The docs list sqlite3 as the only supported dialect, but `config.go` does no validation. Unverified.
- Plan section 7: listen address `Addr: ":<port>"` in `server/server.go`. Not fetched.
- Plan section 11: log lines "Creating default user." and "Start listening". Not fetched.
- Plan section 4: the `traggo` binary is placed in `/app`, but the upstream image runs from `/opt/traggo` (WORKDIR). The plan's own layout is a design choice; not an error.
- TrueCharts service port 12117 vs upstream 3030: noted in the chart summary; not in plan.md.
