# NginxProxyManager/nginx-proxy-manager docker/Dockerfile (v2.17.1)

**Source:** https://raw.githubusercontent.com/NginxProxyManager/nginx-proxy-manager/v2.17.1/docker/Dockerfile (fetched 2026-11-26; blob URL in urls.txt is the same file)

## Stages
| Stage | Image | Notes |
|---|---|---|
| testca | nginxproxymanager/testca (no tag) | test root CA cert source |
| final | ${BASE_IMAGE} = nginxproxymanager/nginx-full:certbot-node | published image |

- Header: intended for `docker buildx`; frontend must be prebuilt via `./scripts/frontend-build`.

## ARG
| ARG | Default |
|---|---|
| BASE_IMAGE | nginxproxymanager/nginx-full:certbot-node |
| TARGETPLATFORM | none |
| BUILD_VERSION / BUILD_COMMIT / BUILD_DATE | none |

## ENV
| Name | Value |
|---|---|
| SUPPRESS_NO_CONFIG_WARNING | 1 |
| S6_BEHAVIOUR_IF_STAGE2_FAILS | 1 |
| S6_CMD_WAIT_FOR_SERVICES_MAXTIME | 0 |
| S6_FIX_ATTRS_HIDDEN | 1 |
| S6_KILL_FINISH_MAXTIME | 10000 |
| S6_VERBOSITY | 1 |
| NODE_ENV | production |
| NPM_BUILD_VERSION / COMMIT / DATE | from build ARGs |
| NODE_OPTIONS | --openssl-legacy-provider |

## Build steps (in order)
1. Write `fs.file-max = 65535` to /etc/sysctl.conf
2. apt-get (--no-install-recommends): jq, logrotate; lists cleaned
3. s6-overlay via docker/scripts/install-s6 (TARGETPLATFORM), script deleted after
4. Copy backend -> /app, frontend/dist -> /app/frontend, docker/rootfs -> /
5. Copy testca root cert -> /etc/ssl/certs/NginxProxyManager.crt; symlink 1d0e3f10.0; update-ca-certificates
6. WORKDIR /app; `yarn install`; `yarn cache clean`
7. Remove s6 user service `frontend` (/etc/s6-overlay/s6-rc.d/user/contents.d/frontend) and /etc/nginx/conf.d/dev.conf
8. chmod 644 /etc/logrotate.d/nginx-proxy-manager

## Runtime
| Item | Value |
|---|---|
| USER | not set (root) |
| EXPOSE | 80, 81, 443 |
| VOLUME | /data |
| ENTRYPOINT | /init (s6) |
| CMD | not set |
| HEALTHCHECK | not set |
| WORKDIR | /etc/ssl/certs, then /app |

## Paths
- /app (app), /app/frontend, /data, /etc/ssl/certs/NginxProxyManager.crt, /etc/logrotate.d/nginx-proxy-manager, /etc/s6-overlay/s6-rc.d/, /etc/sysctl.conf
- Letsencrypt/log paths not in this file (from docker/rootfs).

## Labels
- license MIT; name nginx-proxy-manager; source https://github.com/jc21/nginx-proxy-manager
