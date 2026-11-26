# Context index: guacd

Fetched 2026-11-26.

## Sources summarised

| Source URL | Summary file |
| --- | --- |
| https://github.com/apache/guacamole-server | github-apache-guacamole-server.md |
| https://raw.githubusercontent.com/apache/guacamole-server/1f664e08feae6e7d15d8146b78acab2e6fb470ae/Dockerfile | github-apache-guacamole-server.md |
| https://github.com/apache/guacamole-server/blob/1f664e08feae6e7d15d8146b78acab2e6fb470ae/Dockerfile | github-apache-guacamole-server.md (same file as raw) |
| https://raw.githubusercontent.com/apache/guacamole-server/1f664e08feae6e7d15d8146b78acab2e6fb470ae/src/guacd-docker/bin/entrypoint.sh | github-apache-guacamole-server.md |
| https://raw.githubusercontent.com/apache/guacamole-server/1f664e08feae6e7d15d8146b78acab2e6fb470ae/src/guacd/conf-args.c | github-apache-guacamole-server.md |
| https://raw.githubusercontent.com/apache/guacamole-server/1f664e08feae6e7d15d8146b78acab2e6fb470ae/src/guacd/conf.h | github-apache-guacamole-server.md |
| https://raw.githubusercontent.com/apache/guacamole-server/1f664e08feae6e7d15d8146b78acab2e6fb470ae/src/guacd/daemon.c | github-apache-guacamole-server.md |
| https://archive.apache.org/dist/guacamole/1.6.0/source/guacamole-server-1.6.0.tar.gz.sha256 | archive-apache-guacamole-server-1.6.0.md |
| https://hub.docker.com/r/guacamole/guacd | dockerhub-guacamole-guacd.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/guacd | truecharts-guacd.md (values.yaml fetched; listing not fetched) |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/guacd/values.yaml | truecharts-guacd.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page (only the user can sign) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://archive.apache.org/dist/guacamole/1.6.0/source/guacamole-server-1.6.0.tar.gz | direct source tarball download (plan.md); checksum recorded, tarball not downloaded |
| https://github.com/apache/guacamole-server/archive/... | not used |
| http://guacamole.apache.org/doc/gug/ | documentation index, not fetched (budget; the source files were enough for the daemon facts) |
| http://guacamole.apache.org/ | project website, not fetched (budget) |
| https://issues.apache.org/jira/browse/GUACAMOLE/ | bug tracker, not needed |
| ghcr.io/trueforge-org/ubuntu | ghcr image ref, not a web page |
| https://github.com/libssh2/libssh2, https://github.com/seanmiddleditch/libtelnet, https://github.com/LibVNC/libvncserver, https://github.com/warmcat/libwebsockets, https://github.com/FreeRDP/FreeRDP | build-time dependency repos used by the upstream Dockerfile; plan builds from Ubuntu packages instead; not fetched |
| `apt:guacd` / packages.ubuntu.com | apt package search was in plan.md section 1 (not re-checked in this run) |

## Fetch failures

- https://raw.githubusercontent.com/apache/guacamole-server/1f664e08feae6e7d15d8146b78acab2e6fb470ae/entrypoint.sh: HTTP 404. Retried at `src/guacd-docker/bin/entrypoint.sh` (the Dockerfile COPY path), which succeeded.
- Hub page: architectures not shown.

## plan.md corrections

One edit made, in section 9, the adaptations table:
- old: `Chart runAsUser 1000/runAsGroup 1001, readOnlyRootFilesystem: false`
- new: `Chart runAsUser 1000/runAsGroup 1000, readOnlyRootFilesystem: false`
- source: `context/truecharts-guacd.md` (values.yaml: `runAsGroup: "1000"`)

Noted, not edited (unverified or omissions):
- plan.md section 1 runtime package list omits `util-linux-login`, which the upstream runtime stage installs. Omission only; the plan's list is "the packages upstream installs" so it is incomplete, but not a fact error. Not edited.
- plan.md section 4 and 9 say the chart mounts recordings and drive volumes. The guacd values file has no persistence. Unverified here (may be the `guacamole` web chart).
- plan.md section 3 says `/healthcheck.sh` reads `/container-test.yaml` in the ubuntu base. Not checked here (include/healthcheck.sh not in this context).
- plan.md section 1 says the Ubuntu `apt` package `guacd` is missing for resolute and that jammy/noble have 1.3.0. packages.ubuntu.com was not fetched in this run. Unverified here.
- plan.md section 1 says Renovate tags have no `v` prefix. Not checked (tags page not fetched). Unverified.
