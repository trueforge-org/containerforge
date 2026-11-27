# npm: @actual-app/sync-server@26.11.0

**Source URL(s):** https://registry.npmjs.org/@actual-app/sync-server/26.11.0 (fetched 2026-11-27)

## What it is
- Name `@actual-app/sync-server`, version `26.11.0`, license MIT.
- `bin`: `actual-server` -> `build/bin/actual-server.js`.
- `engines.node`: `>=22.19.0`.

## Runtime deps (selected, from package.json)
- `@actual-app/web` 26.11.0, `@actual-app/crdt` 3.1.4
- `express` ^5.3.0, `better-sqlite3` ^13.0.3, `argon2` ^0.45.1, `bcrypt` ^6.0.0, `openid-client` ^5.7.1, `winston` ^3.19.0, `convict` ^6.2.5, `undici` ^7.25.0, `akahu` ^2.5.1, `pluggy-sdk` ^0.92.0, `express-rate-limit` ^8.7.1, `migrate` ^2.1.0 (others: jws, cors, uuid, debug, date-fns, ipaddr.js, express-winston).

## Install steps
- `npm install --omit=dev @actual-app/sync-server@26.11.0` (pin exact version).
- Native deps (better-sqlite3, argon2, bcrypt) need a build toolchain where no prebuilt binary exists (not verified from registry metadata).

## Entrypoint
- `actual-server` (bin) -> `build/bin/actual-server.js`.

## Gotchas
- Node >=22.19.0 required.
