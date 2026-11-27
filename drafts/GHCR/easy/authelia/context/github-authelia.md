# authelia/authelia (upstream repo, Dockerfile at 8da42b2) and authelia/chartrepo
Source URL(s): https://raw.githubusercontent.com/authelia/authelia/8da42b2348b0351c6284a2940a9c5eec3d4cd3fd/Dockerfile (fetched; blob variant same), https://raw.githubusercontent.com/authelia/authelia/master/README.md (fetched, badges + intro only), https://github.com/authelia/authelia (repo), https://github.com/authelia/chartrepo (repo page, description only: "Authelia Helm Charts")

## What it is
Open-source authentication/authorization server and portal: MFA and SSO for web apps, OpenID Connect 1.0 provider.

## Build (Dockerfile at 8da42b2)
- SPDX header: Apache-2.0
- `ARG TAG`, `ARG SHA`; `FROM authelia/base:${TAG}@sha256:${SHA}` (upstream image is built on their own base)
- ARG TARGETOS, TARGETARCH
- `COPY --link authelia-${TARGETOS}-${TARGETARCH}/authelia LICENSE entrypoint.sh healthcheck.sh ./` (into /app)
- `COPY --link --chmod=666 .healthcheck.env ./`
- Files prebuilt by release pipeline (not compiled in Dockerfile)

## Entrypoint / healthcheck
- `ENTRYPOINT ["/app/entrypoint.sh"]`
- `HEALTHCHECK --interval=30s --timeout=3s --start-period=1m CMD /app/healthcheck.sh`

## Env (Dockerfile)
| Name | Value |
| --- | --- |
| PATH | /app:${PATH} |
| PUID | 0 |
| PGID | 0 |
| X_AUTHELIA_CONFIG | /config/configuration.yml |

## Ports
- EXPOSE 9091

## Volumes / paths
- Binary in /app; config path /config/configuration.yml (default)

## User/UID
- No USER directive in Dockerfile; PUID/PGID 0 in env (upstream base handles dropping; not used by our base)

## Gotchas
- Upstream image depends on `authelia/base`; the plan does not reuse it (PUID/PGID handling not needed)
- Healthcheck script shipped in /app; chart disables built-in server healthcheck
