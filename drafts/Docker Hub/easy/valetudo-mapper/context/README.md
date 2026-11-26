# context/ for valetudo-mapper

Fetched 2026-11-26.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/rand256/valetudo-mapper (Dockerfile, README, package.json, app.js, lib/Configuration.js @54aba35) | github-rand256-valetudo-mapper.md |
| https://hub.docker.com/r/rand256/valetudo-mapper | dockerhub-rand256-valetudo-mapper.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/valetudo-mapper (values.yaml) | truecharts-valetudo-mapper.md |
| https://valetudo.cloud/ | not fetched (see Fetch failures) |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page, not a source.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base link.
- https://github.com/rand256/valetudo-mapper/archive/refs/heads/master.zip and https://github.com/rand256/valetudo-mapper/archive/${VALETUDO_MAPPER_COMMIT}.tar.gz (and the `<commit` placeholder form): direct source archives (pattern recorded in the GitHub summary).
- https://github.com/rand256/valetudo-mapper/blob/54aba3534e9e797b9a22c0e134fa2706effd2e9d/Dockerfile: fetched raw instead.
- Local reference `docs/project-fireball.md` is not a web source.

## Fetch failures

- https://valetudo.cloud/: listed in the draft as the Valetudo project site. Not fetched in this batch. Not required for build facts; the README links the fork at `github.com/rand256/valetudo`, which was not fetched.
- `lib/Webserver.js`, `lib/MqttClient.js`, `lib/RRMapParser.js`: not fetched. Affects: the exact `/api/map/raw` route, `listen()` host, MQTT reconnect and exit behaviour, and the `Loading configuration file` log text. These remain unverified.
- GitHub repo page: last commit date and license not confirmed (no `license` field in package.json).

## plan.md corrections

None made. Verified and consistent: upstream Dockerfile (`node:lts-alpine`, `npm install && touch config.json`, `CMD npm start`); `package.json` version `0.5.0` and dependency versions; the `-f` and `-c` CLI behaviour; the default config values (`webserver` enabled false, port 3000; `mqtt.broker_url` placeholder); no env vars read in `app.js`; the seed path works because the file exists before start.

Items left as unverified or incomplete (not edited):
- Plan section 1: "License Apache-2.0 (GitHub API)". `package.json` has no `license` field and LICENSE was not fetched. Unverified.
- Plan section 1 and 4: "`/api/map/image` and `/api/map/raw`". Only `/api/map/image` is documented in the README. `/api/map/raw` unverified (`lib/Webserver.js` not fetched).
- Plan section 1: "the web server starts only if `webserver.enabled === true`". Incomplete: `app.js` also requires an `mqtt` block for the web server to start (the web server is nested in the MQTT branch). The seeded default includes `mqtt`, so the plan's start.sh remains valid. Not edited (not wrong, just incomplete).
- Plan section 11: "Loading configuration file: /config/config.json (message verified in source)". The message text was not seen in the fetched files (`Configuration.js` was fetched, and its only load-time message is the `-c` prompt). Unverified; the plan's "verified" wording is not supported by this fetch.
- Plan section 10: "the mapper reads valetudo/<identifier>/map_data from MQTT". Consistent with the README `mapDataTopic` `valetudo/rockrobo/map_data`.
- Plan section 1 claim: "`-f <path>` ... without `-f` it uses `../config.json`". Verified.
- Plan section 7: `start.sh` seeds the file before `node app.js -f`. This also avoids the exit-1 path for a missing `-f` file without `-c` (verified).
