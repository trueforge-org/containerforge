# aloysius-pgast/crypto-exchanges-gateway (upstream)

## Source URL(s) + date
- https://raw.githubusercontent.com/aloysius-pgast/crypto-exchanges-gateway/master/docker/Dockerfile
- https://raw.githubusercontent.com/aloysius-pgast/crypto-exchanges-gateway/master/README.md
- https://api.github.com/repos/aloysius-pgast/crypto-exchanges-gateway/releases/latest (fetched 2026-11-26)

## What it is
Self-hosted REST + WebSocket gateway to crypto exchanges (Binance, Bittrex, Kucoin, OKEx, Poloniex), with optional UI and Pushover alerts. README: "won't build unless you use node 14.x"; upstream "unlikely to be updated".

## Install/build steps (upstream Dockerfile, multi-stage)
- Stage `gateway`: `FROM apendergast/ceg-docker-base:gateway-latest`
- Stage `ui`: `FROM apendergast/ceg-docker-base:ui-latest`
- Build args: `GIT_BRANCH=master`, `TIMESTAMP=0`
- Gateway build: `git clone https://github.com/aloysius-pgast/crypto-exchanges-gateway.git` in `/root/`, `git checkout $GIT_BRANCH`, copy `/root/dummy/gateway/node_modules`, `npm install --unsafe-perm`, `cp docker/config.docker.json config/config.json`
- UI build: `cd crypto-exchanges-gateway/ui`, copy `/root/dummy/ui/node_modules`, `npm install --unsafe-perm && npm run build && rm -fr node_modules`
- Final stage: `FROM apendergast/alpine-node:runtime-latest`, `WORKDIR /root/crypto-exchanges-gateway/`, `COPY --from=ui /root/crypto-exchanges-gateway .`

## Runtime deps
- Node.js (README: node 14.x required to build). Final base is alpine-node runtime.

## Entrypoint/flags
- `CMD ["node", "./gateway.js"]`

## Env vars (ENV in upstream Dockerfile, all default shown)
| Var | Default |
| --- | --- |
| cfg.auth.apikey | "" |
| cfg.listen.externalEndpoint | "" |
| cfg.listenWs.externalEndpoint | "" |
| cfg.sessions.maxSubscriptions | "0" |
| cfg.sessions.maxDuration | "0" |
| cfg.pushover.user | "" |
| cfg.pushover.token | "" |
| cfg.tickerMonitor.enabled | "1" |
| cfg.marketCap.enabled | "1" |
| cfg.fxConverter.enabled | "1" |
| cfg.exchanges.poloniex.enabled / .key / .secret | "1" / "" / "" |
| cfg.exchanges.bittrex.enabled / .key / .secret | "1" / "" / "" |
| cfg.exchanges.binance.enabled / .requirePair / .key / .secret | "1" / "0" / "" / "" |
| cfg.exchanges.kucoin.enabled / .requirePair / .key / .secret / .password | "1" / "0" / "" / "" / "" |
| cfg.exchanges.okex.enabled / .requirePair / .key / .secret / .password | "1" / "0" / "" / "" / "" |

## Ports
- 8000 (HTTP REST/UI), 8001 (WebSocket). Both `EXPOSE`d.

## Volumes/paths
- `/root/crypto-exchanges-gateway/ssl`
- `/root/crypto-exchanges-gateway/storage/db`
- `/root/crypto-exchanges-gateway/custom_config`

## User/UID
- Not set in Dockerfile (runs as root).

## Config files
- Built-in config: `config/config.json` copied from `docker/config.docker.json` at build time.
- Upstream README: `config/config.sample.json` -> `config/config.json`; docs in `doc/config.adoc` (not fetched).

## Healthcheck
- None in upstream Dockerfile. README verification: `GET http://127.0.0.1:8000/exchanges/` returns JSON list of enabled exchanges.

## Version/asset naming
- Latest release (API): tag `1.13.2`, published 2023-11-11, no assets (source-only). Release notes: "fix: fix `binance` pairs retrieval".
- Build is from git `master` (not tag) by default via `GIT_BRANCH` arg.

## Arch
- Not stated upstream.

## Gotchas
- Upstream README: builds only with node 14.x.
- Build clones upstream from GitHub at build time (`TIMESTAMP` arg busts cache).
- Dockerfile uses `--unsafe-perm` npm installs.
- Dependency images `apendergast/ceg-docker-base:*` and `apendergast/alpine-node:runtime-latest` are external, unpinned `-latest` tags.
- Upstream says the project is "unlikely to be updated".
