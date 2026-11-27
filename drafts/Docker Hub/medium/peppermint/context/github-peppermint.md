# GitHub: Peppermint-Lab/peppermint

## Source URL(s) + date
- https://api.github.com/repos/Peppermint-Lab/peppermint/releases/latest
- https://raw.githubusercontent.com/Peppermint-Lab/peppermint/ba6e2179f9409db76abeb9a3007a262160e24628/dockerfile
- Fetched 2026-11-27

## Latest release
- tag `0.5.5`, published 2024-11-14T23:42:34Z, no release assets.

## Dockerfile (pinned commit ba6e2179f9409db76abeb9a3007a262160e24628)
### Install/build steps
- Stage `builder`: `FROM node:lts AS builder` (unpinned tag), `WORKDIR /app`.
- `apt-get install -y build-essential python3`.
- `npm i -g prisma`; `npm i -g typescript@latest -g --force`.
- API: `cd apps/api && npm install --production`, then `npm i --save-dev @types/node && npm run build`.
- Client: `cd apps/client && yarn install --production --ignore-scripts --prefer-offline --network-timeout 1000000`, then `yarn add --dev typescript @types/node`, then `yarn build`.
- Stage `runner`: `FROM node:lts AS runner`, `npm install -g pm2`.

### Copies (runner)
- `/app/apps/api/` from builder.
- `/app/apps/client/.next/standalone` to `./apps/client`; `.next/static` and `public` into client.
- `ecosystem.config.js` (PM2 config; contents not fetched).

### Runtime
- `EXPOSE 3000 5003`
- `CMD ["pm2-runtime", "ecosystem.config.js"]`
- No ENV, USER, VOLUME or ENTRYPOINT in the Dockerfile (runs as root by default).
- No start shell script; only `ecosystem.config.js` drives startup.

## Gotchas
- Base `node:lts` is a floating tag.
- Runs as root (no USER directive); PM2 runs both API and client.
- Dockerfile is at a commit hash, not the release tag; release 0.5.5 has no assets.
- Not fetched: repo API (`/repos/Peppermint-Lab/peppermint`), `ecosystem.config.js`, `peppermint.sh` home page (budget).
