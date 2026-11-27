# Upstream app: magne4000/quassel-webserver (package.json, app.js, settings.cjs)

Source URLs (fetched 2026-11-27):
- https://api.github.com/repos/magne4000/quassel-webserver/contents/package.json (base64 decoded)
- https://api.github.com/repos/magne4000/quassel-webserver/contents/app.js (base64 decoded)
- https://api.github.com/repos/magne4000/quassel-webserver/contents/settings.cjs: HTTP 403. Alternative used: https://raw.githubusercontent.com/magne4000/quassel-webserver/master/settings.cjs (OK).

## package.json
- name `quassel-webserver`, version `3.0.2`, `"type": "module"`, license MIT.
- scripts: `start` = `node app.js`; `dev` = `nodemon app.js -m http -p 64111`; no build script.
- engines: node >= 16.
- deps: libquassel ^4.0.0, express ^4.18.2, ws ^8.14.2, body-parser, cookie-parser, commander ^11.1.0, less, less-middleware, morgan, pug ^3.0.2, resolve-esm, serve-favicon, untildify.
- optional: @httptoolkit/httpolyglot ^2.1.1. dev: nodemon ^3.0.1.

## app.js
- `--config <path>` via commander. Settings loaded before `run()`. Webserver values fill CLI options not given.
- Flags: `-s/--socket`, `-l/--listen` (default 0.0.0.0), `-p/--port`, `-m/--mode` (http|https).
- Mode: no socket and mode unset defaults to https. http: port 64080. https: port 64443 (httpolyglot, redirect to https; fallback plain https). Other mode: exit 5.
- Listen: TCP `listen(port, host)`. Socket: `listen(socket)` with chmod 666.
- prefixpath: must not contain `../` (exit 3) and must start with `/` (exit 4). Mounted via express static and less.
- HTTPS needs `ssl/key.pem` (exit 1) and `ssl/cert.pem` (exit 2), relative to app dir.
- Views in `views/` (pug). Static root `public/`. Favicon `public/favicon.ico`.
- libquassel dist: `libquassel/dist/libquassel.js` (+ .map).

## settings.cjs (defaults)
- Browser-overridable: `host: ''`, `port: 4242` (core), `initialBacklogLimit: 20`, `backlogLimit: 100`, `securecore: true`, `theme: 'default'`, `perchathistory: true`, `displayfullhostmask: false`, `emptybufferonswitch: false`, `highlightmode: 2`.
- webserver: `socket: false`, `listen: null`, `port: null` (64080 http / 64443 https), `mode: null` (defaults https).
- Top-level: `themes: ['default','darksolarized']`, `forcedefault: false`, `prefixpath: ''`.

## Gotchas
- Core host and port set in settings; LSIO s6 script rewrites `host:`, `port:`, `prefixpath:`, `mode:` via sed.
- Node >= 16 required by package.json.
