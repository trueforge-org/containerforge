# Context sources: quassel-web

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/quassel-web/values.yaml | truecharts-quassel-web.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/quassel-web/Chart.yaml | truecharts-quassel-web.md |
| https://hub.docker.com/v2/repositories/linuxserver/quassel-web/ | dockerhub-quassel-web.md |
| https://api.github.com/repos/linuxserver/docker-quassel-web/contents/Dockerfile | linuxserver-dockerfile.md |
| https://api.github.com/repos/linuxserver/docker-quassel-web | linuxserver-repo-meta.md |
| https://api.github.com/repos/linuxserver/docker-quassel-web/contents/root/etc/s6-overlay/s6-rc.d/init-quassel-web-config/run | linuxserver-s6-scripts.md |
| https://api.github.com/repos/linuxserver/docker-quassel-web/contents/root/etc/s6-overlay/s6-rc.d/svc-quassel-web/run | linuxserver-s6-scripts.md |
| https://api.github.com/repos/magne4000/quassel-webserver | upstream-repo.md |
| https://api.github.com/repos/magne4000/quassel-webserver/commits/master | upstream-repo.md |
| https://api.github.com/repos/magne4000/quassel-webserver/tags | upstream-repo.md |
| https://api.github.com/repos/magne4000/quassel-webserver/contents/package.json | upstream-app.md |
| https://api.github.com/repos/magne4000/quassel-webserver/contents/app.js | upstream-app.md |
| https://api.github.com/repos/magne4000/quassel-webserver/contents/settings.cjs | upstream-app.md (403; content from raw alt below) |
| https://raw.githubusercontent.com/magne4000/quassel-webserver/master/settings.cjs | upstream-app.md (alternative, OK) |

Skipped categories:
- Duplicates: github.com blob/repo-root URLs (linuxserver/docker-quassel-web, magne4000/quassel-webserver, Dockerfile blob).
- Binary: source tarball `archive/${QUASSELWEB_COMMIT}.tar.gz` (not fetched).
- Templated/other: none in list.

Failures (1):
- https://api.github.com/repos/magne4000/quassel-webserver/contents/settings.cjs: HTTP 403. Recovered via one raw alternative (above). Not a failure in the final output.

## plan.md corrections
- None. Verified against fetched sources: base `baseimage-alpine:3.20`, MIT license (upstream API), ports 64080/64443, `settings.cjs` defaults, s6 scripts (settings-env.cjs, settings-user.cjs, `node app.js --config`), and archived linuxserver repo (last push 2024-12-26).
- Not checked here, so not changed: `LICENSE-MIT` and `package-lock.json` in upstream master (plan claims both), `engines` Node >= 16 vs Node in python-node, and the README `npm install --production` line.
