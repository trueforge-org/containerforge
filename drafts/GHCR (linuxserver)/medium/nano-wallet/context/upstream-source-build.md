# Upstream source: linuxserver/nano-wallet (package.json + README + LICENSE)

Source URLs (fetched 2026-11-27):
- https://api.github.com/repos/linuxserver/nano-wallet/contents/package.json (base64 decoded)
- https://api.github.com/repos/linuxserver/nano-wallet/readme (base64 decoded)
- https://raw.githubusercontent.com/linuxserver/nano-wallet/master/LICENSE

## License
- GNU GPL v3 (29 June 2007), "Copyright (C) 2007 Free Software Foundation, Inc." (license text).

## package.json
- name `LSIO-Nano-Wallet`, version `1.3.2`, `private: true`, no `main`.
- Scripts: `serve` (vue-cli-service serve), `build` (vue-cli-service build), `lint`. No `start`.
- No `engines` field. `node-sass` ^4.12.0 suggests an old Node release.
- Build tooling: `@vue/cli-service` ~4.3.0, vue-template-compiler ^2.6.11, sass-loader ^8.0.2, worker-loader ^2.0.0, eslint ^6.7.2.
- Runtime: vue ^2.6.11, vue-router ^3.1.6, vuex ^3.4.0, `@thelamer/nanocurrency` ^2.5.1, bignumber.js, numbro, jsqr, qrcode, qr-code-styling, core-js.
- browserslist: "> 1%", "last 2 versions", "not dead".

## README (build and run)
- `npm install`, `npm run build` (production), `npm run serve` (dev), `npm run lint`.
- Dist output dir not stated (Vue CLI default `dist`, inference only).
- Upstream CI (`.github/workflows/main.yml`) publishes to gh-pages (not used in image).
- RPC endpoint config: `src/stores/app/state.js` (`node` array, fallback servers). Node RPC must allow `block_count`.
- Branding: site title in `.env`; icons `/public/qr_logo.png`, `public/wallet_logo.png`.
- Wallet is client-side only; no local storage; private key entered each session.
- Wallet URL can preselect a node: `https://<host>/#/<rpc-host>`.
- Companion node image: linuxserver/nano.

## Gotchas
- `node-sass` ^4 needs native build or prebuilt binary matched to the Node version. Build tools are dated (Vue CLI 4.3).
