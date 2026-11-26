# TrueCharts chart: bitcoind

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/bitcoind (listed in draft)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bitcoind/values.yaml (fetched 2026-11-26)

**Config (values.yaml)**
- Image `docker.io/ofawx/bitcoind` tag `latest@sha256:e771b04f121b76fb0aa2e8b511c3ac58c7cf82371ae5312ba24fc78698dc7e91`, pullPolicy `IfNotPresent`.
- Ports: `main` 8333/tcp (P2P by convention); `localrpc` 8332/tcp (RPC by convention; the chart service is enabled). Neither is labelled in the chart.
- Persistence `data`: enabled, mounted at `/root/.bitcoin/`. No size or storage class.
- securityContext (container): runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false; runAsNonRoot and privileged not set.
- Env: none. bitcoin.conf / args: none. Probes: none.

**Gotchas**
- Chart data path `/root/.bitcoin/` is the default datadir of root; plan.md moves it to `/config` via `-datadir=/config`. Existing chart data must be moved and chowned.
- The chart does not set a `bitcoin.conf` or args, so RPC auth and allow-list are not configured by the chart (consistent with plan.md's `BITCOIN_RPCAUTH` and `BITCOIN_RPCALLOWIP` env design).
