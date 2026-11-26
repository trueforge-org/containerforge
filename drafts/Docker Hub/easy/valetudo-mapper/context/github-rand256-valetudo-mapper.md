# rand256/valetudo-mapper (application source, Dockerfile, package.json, app.js, README, Configuration.js)

**Source URL(s) + fetch date**
- https://github.com/rand256/valetudo-mapper (repo root, fetched 2026-11-26)
- https://raw.githubusercontent.com/rand256/valetudo-mapper/54aba3534e9e797b9a22c0e134fa2706effd2e9d/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/rand256/valetudo-mapper/54aba3534e9e797b9a22c0e134fa2706effd2e9d/README.md (fetched 2026-11-26)
- https://raw.githubusercontent.com/rand256/valetudo-mapper/54aba3534e9e797b9a22c0e134fa2706effd2e9d/package.json (fetched 2026-11-26)
- https://raw.githubusercontent.com/rand256/valetudo-mapper/54aba3534e9e797b9a22c0e134fa2706effd2e9d/app.js (fetched 2026-11-26)
- https://raw.githubusercontent.com/rand256/valetudo-mapper/54aba3534e9e797b9a22c0e134fa2706effd2e9d/lib/Configuration.js (fetched 2026-11-26)
- https://github.com/rand256/valetudo-mapper/archive/refs/heads/master.zip and `.../archive/<commit>.tar.gz`: direct archives, not fetched (pattern below).
- https://valetudo.cloud/ (Valetudo project site, listed in the draft): not fetched (see README file).

**What it is**
A companion service for Valetudo (the rand256 fork of Valetudo for Xiaomi/Roborock robots). It reads the robot's map data from MQTT and renders PNG maps, served over HTTP and/or published to MQTT. Node.js (`app.js`). The robot's IP is not needed; MQTT is the data path.

**Install/build steps and build deps (upstream Dockerfile at 54aba35)**
- `FROM node:lts-alpine`, `WORKDIR /app`
- `COPY package.json /app`, `RUN npm install && touch config.json`, `COPY . /app`
- `CMD ["npm", "start"]`
- No ARG, ENV, EXPOSE, USER, VOLUME or ENTRYPOINT.
- Native: `npm start` (README).

**Runtime deps** (`package.json`, version `0.5.0`)
- `jimp` `^0.16.1`, `mqtt` `^4.3.7`, `compression` `^1.7.2`, `express` `^4.18.1`
- `scripts.start` = `node app.js`
- No `license`, `main` or `engines` fields. No lockfile in the repo (plan.md file list).

**Binaries/entrypoint/CLI flags**
- Entry: `node app.js`.
- Args via `process.argv.slice(2)`:
  - `-f <path>`: `customConfigPath` (value after `-f`; null if absent or last).
  - `-c`: `customConfigCreate` (boolean).
- No `process.env` reads in `app.js`.

**Config path behaviour (`lib/Configuration.js`)**
- With `-f <path>`: `this.location = path.resolve(customConfigPath)`.
- Without `-f`: `this.location = path.join(__dirname, "../config.json")` (next to the app).
- If `-f` points to a missing file and `-c` is not set: prints `Please use "-c" flag to create it or check the path is valid` and exits with code 1.
- Otherwise, a missing file is created: parent dir made with `Tools.MK_DIR_PATH`, then `persist()`.
- `persist()` writes the whole settings object with `fs.writeFileSync(this.location, JSON.stringify(this.settings, null, 2))`. It runs after load when the merged settings differ from the file, when the file is created, and on every `set()`.
- Loading is a shallow `Object.assign` merge over defaults, so a block in the file replaces the default block. Legacy `mqtt.mapSettings` moves to the root.
- Malformed JSON: logs an error and `process.exit(1)`.

**Default config (`Configuration.js` settings)**

| Block | Keys and defaults |
|---|---|
| `mqtt` | `identifier` `rockrobo`, `deviceName` `mapper`, `topicPrefix` `valetudo`, `autoconfPrefix` `homeassistant`, `broker_url` `mqtt://user:pass@foobar.example`, `caPath` `""`, `mapDataTopic` `valetudo/rockrobo/map_data`, `minMillisecondsBetweenMapUpdates` `10000`, `publishMapImage` `true`, `publishMapData` `false` |
| `mapSettings` | `drawPath` true, `drawCharger` true, `drawRobot` true, `drawCurrentlyCleanedZones` false, `drawCurrentlyCleanedBlocks` false, `drawForbiddenZones` true, `drawVirtualWalls` true, `scale` 4, `gradientBackground` true, `autoCrop` 20, `rotate` false (`rotate` 90 in the README example) |
| `webserver` | `enabled` false, `port` 3000 |

**Start order (`app.js`)**
1. `Configuration` is created from the options.
2. Only if `conf.get("mqtt")` is truthy: `MqttClient` is created with `webserverEnabled` (= `webserver.enabled === true`) and a shared `EventEmitter`.
3. The web server starts inside that same branch, only if `webserver.enabled === true`: `new WebServer({ port: webserver.port, events })`.
4. Without an `mqtt` block: `console.error("Missing configuration.mqtt")`, no exit, no throw. Web server does not start.
- MQTT error and reconnect behaviour are in `lib/MqttClient.js` (not fetched).

**Ports**
3000/tcp (default `webserver.port`). Listens on all interfaces (`listen(port)` with no host, per plan.md; `lib/Webserver.js` not fetched).

**Endpoints**
- `/api/map/image`: PNG of the map (README: the only endpoint mentioned).
- `/api/map/raw`: plan.md says it exists; not documented in the README and `lib/Webserver.js` not fetched. UNVERIFIED.

**MQTT settings (README)**
- Broker: `mqtt://user:pass@example.com:port` (`broker_url`), optional `caPath`.
- Map topic: `valetudo/rockrobo/map_data` (`mapDataTopic`). It is shared with the robot's Valetudo fork via the same broker.
- Home Assistant autoconfig prefix `homeassistant`. `minMillisecondsBetweenMapUpdates` 10000.
- MQTT is required: the mapper reads map data from the broker, not from the robot over the LAN.

**Volumes/paths and persistent data**
- Config file only. Native default is `../config.json` relative to `app.js`. Container: README says map your file to `/app/config.json` (the only volume described). The Dockerfile's `touch config.json` creates an empty file at `/app/config.json`.
- The app writes config back on every change (`persist()`), so the config path must be writable.

**User/UID & permissions**
No USER directive upstream (runs as root on `node:lts-alpine`).

**Config files and formats**
JSON (`config.json`). See the defaults table. Persist writes two-space JSON.

**Healthcheck/readiness endpoints**
None documented. The web server, when enabled, serves `/api/map/image`.

**Version/release info and asset naming**
- `package.json` `version` `0.5.0`. No GitHub releases or tags (plan.md; the repo page shows none).
- Pinned commit `54aba3534e9e797b9a22c0e134fa2706effd2e9d` (plan.md: 2023-09-15 last push; not confirmed here).
- Archive pattern: `https://github.com/rand256/valetudo-mapper/archive/<commit>.tar.gz` (plan.md).

**Arch support**
Pure JavaScript dependencies (plan.md: jimp and mqtt are pure JS). `node:lts-alpine` base is multi-arch.

**Licence**
Plan.md says Apache-2.0 (GitHub API). `package.json` has no `license` field and the LICENSE file was not fetched. UNVERIFIED.

**Gotchas**
- `-f` pointing to a missing file without `-c` exits 1. The plan's `start.sh` seeds the file first, so this is avoided.
- The web server starts only inside the `mqtt` branch, so an `mqtt` block must be present as well as `webserver.enabled: true`.
- Shallow config merge: a partial `mqtt` or `webserver` block in the file replaces the default block entirely.
- Default `broker_url` is a placeholder (`mqtt://user:pass@foobar.example`); the app will try to connect to it.
- `npm install` with no lockfile resolves fresh versions each build.
- Legacy and version drift: the Docker Hub image `rand256/valetudo-mapper` (latest, last updated about 3 years ago) predates this source at the pinned commit.
