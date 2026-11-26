# grafana/grafana: Dockerfile (pinned commit 5db6ba88...)
Source URL(s): https://github.com/grafana/grafana/blob/5db6ba887630c7fa12e5bfd063f2fa854025468c/Dockerfile = raw.githubusercontent.com/.../5db6ba887630c7fa12e5bfd063f2fa854025468c/Dockerfile (fetched 2026-11-26, 410 lines)
Also fetched: raw main Dockerfile (415 lines). Diff vs pinned: ~75 changed lines, mostly base image patch versions (alpine 3.24.4 on main vs 3.24.3 pinned).

## Base images (pinned)
| Stage | Base |
| --- | --- |
| alpine-base | alpine:3.24.3 |
| ubuntu-base | ubuntu:24.04 |
| go-builder-base | golang:1.27.3-alpine |
| js-builder-base | node:24-alpine (linux/amd64 platform) |
| distroless-base | gcr.io/distroless/static-debian13 |
| enterprise-src | scratch |

## Build args
| ARG | Default |
| --- | --- |
| GO_IMAGE / JS_IMAGE | go-builder-base / js-builder-base |
| GO_SRC / JS_SRC | go-builder / js-builder |
| JS_NODE_ENV | production |
| JS_YARN_INSTALL_FLAG | --immutable |
| JS_YARN_BUILD_FLAG | build |
| GO_BUILD_TAGS / WIRE_TAGS | oss / oss |
| GRAFANA_TGZ | grafana-latest.linux-x64-musl.tar.gz (tgz-builder) |
| GF_UID / GF_GID | 472 / 0 |
| GLIBC_VERSION | 2.40 (alpine final) |
| SLIM | false |
| RUN_SH | ./packaging/docker/run.sh |
| COMMIT_SHA, BUILD_BRANCH, SOURCE_DATE_EPOCH | "" |

## Final targets
- final-alpine: apk add ca-certificates bubblewrap curl tzdata musl-utils; adduser grafana (UID GF_UID, GID GF_GID); COPY run.sh -> /run.sh; USER $GF_UID; ENTRYPOINT ["/run.sh"]
- final-ubuntu: apt-get ca-certificates curl tzdata musl; groupadd/useradd grafana (--create-home); USER $GF_UID; ENTRYPOINT ["/run.sh"]
- final-distroless: USER $GF_UID; ENTRYPOINT ["/usr/share/grafana/bin/grafana", "server", "--homepath=/usr/share/grafana", "--config=/etc/grafana/grafana.ini", "--packaging=docker"]; CMD ["cfg:default.log.mode=console"]
- Last stage in file is `FROM final-alpine` (default build target).
- EXPOSE 3000 in all finals.

## Env (set in stages)
- GF_PATHS_CONFIG=/etc/grafana/grafana.ini
- GF_PATHS_DATA=/var/lib/grafana
- GF_PATHS_HOME=/usr/share/grafana
- GF_PATHS_LOGS=/var/log/grafana
- GF_PATHS_PLUGINS=/var/lib/grafana/plugins
- GF_PATHS_PROVISIONING=/etc/grafana/provisioning
- PATH=/usr/share/grafana/bin:$PATH
- NODE_OPTIONS=--max_old_space_size=8000 (js-builder only)

## Directories created (final stages)
- /var/lib/grafana, /var/log/grafana, /etc/grafana, /usr/share/grafana/.aws, /usr/share/grafana/data/plugins-bundled
- provisioning subdirs: datasources, dashboards, notifiers, plugins, access-control, alerts
- chown to grafana:$GF_GID_NAME

## User / UID
- UID 472 (user grafana), GID 0 (root group), non-root USER at runtime.

## Gotchas
- Env vars follow the GF_<SECTION>_<KEY> convention (e.g. GF_SERVER_HTTP_PORT, GF_DATABASE_TYPE as used by the chart).
- Docs (grafana.com configure-docker) use GF_LOG_MODE, GF_LOG_LEVEL, GF_PLUGINS_PREINSTALL, GF_INSTALL_PLUGINS.
