# souramoo/commentoplusplus Dockerfile (tag v1.8.7)
Source URL(s): https://raw.githubusercontent.com/souramoo/commentoplusplus/v1.8.7/Dockerfile (also github blob URL at same tag), fetched 2026-11-27

## Build stages
| Stage | Base | Packages | Build |
| --- | --- | --- | --- |
| api-build | golang:1.15-alpine | bash dep make git curl g++ | COPY ./api; `make ${RELEASE}` |
| frontend-build | node:12-alpine | bash make python2 g++ | COPY ./frontend; `make ${RELEASE}` |
| templates-db-build | alpine:3.13 | bash make | COPY ./templates and ./db; `make ${RELEASE}` each |
| final | alpine:3.13 | ca-certificates | copies artifacts |

- ARG RELEASE=prod (used for build path build/${RELEASE}/...).
- Final image copies: /commento/commento (binary), /commento/js, css, images, fonts, i18n, *.html, /commento/templates/, /commento/db/.

## Runtime
- WORKDIR /commento/
- ENTRYPOINT ["/commento/commento"] (no CMD)
- EXPOSE 8080
- ENV COMMENTO_BIND_ADDRESS="0.0.0.0"
- No USER directive (root).
- No HEALTHCHECK.

## Build deps / gotchas
- Base images are old (golang 1.15, node 12, alpine 3.13); upstream pin, do not assume current.
- Needs `make prod` in each stage; parallel jobs via nproc.

# README (upstream, fetched 2026-11-27, first 3000 chars)
- Needs PostgreSQL. Env: COMMENTO_ORIGIN (e.g. http://commento.example.com:8080), COMMENTO_PORT (example 8080), COMMENTO_POSTGRES (postgres://user:pass@host:5432/commento?sslmode=disable), COMMENTO_CDN_PREFIX (= COMMENTO_ORIGIN).
- COMMENTO_ENABLE_LOGGING defaults off; set true for page-view logging.
- Wildcard domain support feature present.
- Releases: https://github.com/souramoo/commentoplusplus/releases (pre-compiled binaries).
- Build from source: `make prod` produces ./build/prod/commento (needs nodejs, yarn, golang).
