# TrueCharts: monero-node chart (values.yaml)

**Source URL(s):** https://github.com/trueforge-org/truecharts/tree/master/charts/stable/monero-node (fetched via https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/monero-node/values.yaml)
**Fetched:** 2026-11-26

## Image
- `ghcr.io/sethforprivacy/simple-monerod:v0.18.5.4`, digest begins `1d48b2b2fb22…` (ends `…f7f99c`), IfNotPresent.

## Services
- `main`: port 18080, tcp, targetPort 18080.
- `rpc`: enabled; port 18089, tcp, targetPort 18089.

## Env
- Only `HOME=/home/monero`. No PUID, PGID or TZ set.

## Persistence
- `blockchainstorage`: enabled, mounted at `/home/monero/.bitmonero`. No readOnly, no size.

## Security context
- `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0` (root).

## Probes
None defined.

## Monero settings (chart `monero:` block)
- `rpcbindip: "0.0.0.0"`, `rpcbindport: "18089"`.
- `publicnode: true` (implies `--public-node`; the plan does not set it).
- `noigd: true`, `enablednsblocklist: true`.
- `pruneblockchain: true` (the plan defaults to full sync; the chart prunes; see plan.md section 10).
- No explicit raw flags. Chart maps these values to monerod flags.

## Other
- Schema reference `./values.schema.json`.
