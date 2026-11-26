# Context: xen-orchestra

| Source URL | File |
| --- | --- |
| https://docs.xen-orchestra.com | vatesfr-xen-orchestra.md |
| https://github.com/ronivay/xen-orchestra-docker/blob/0be1b1f87e7895d3cc0091c4088fbfc97317687e/Dockerfile | ronivay-xo-dockerfile-run.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/xen-orchestra | truecharts-xen-orchestra-chart.md |
| https://github.com/vatesfr/xen-orchestra | vatesfr-xen-orchestra.md |
| https://github.com/vatesfr/xen-orchestra/releases | vatesfr-xen-orchestra.md (via api.github.com releases/latest) |
| https://hub.docker.com/r/ronivay/xen-orchestra | dockerhub-and-xen-orchestra-site.md (also ronivay-xo-readme.md for docs) |
| https://xen-orchestra.com | dockerhub-and-xen-orchestra-site.md |

Also fetched (same repos, merged into the files above): ronivay `run.sh`, `healthcheck.sh`, `conf/xo-server.toml.j2`, `conf/monit-services` (in ronivay-xo-dockerfile-run.md and ronivay-xo-config-monit.md).

Skipped categories: none (urls.txt pre-filtered).

Failures:
- ronivay `entrypoint.sh` (guessed path, not in urls.txt): 404. Used `run.sh` instead (it is the Dockerfile CMD).

## plan.md corrections
- None applied. Verified against fetched sources: license AGPL3 (README), Dockerfile node:24-trixie / node:24-trixie-slim, packages, HTTP_PORT default 80, healthcheck, monit/forever process model.
- Unverified (not edited):
  - plan L13 says "No release binaries". The `releases/latest` API returns `xo-lite-v0.27.0` with a tarball asset (XO Lite, not xo-server). Wording may need "no xo-server release binaries".
  - Plan L8/L9 version-to-commit mapping (`5.213.0`, `5.214.0`, `e9760747...`) not checked in this pass.
