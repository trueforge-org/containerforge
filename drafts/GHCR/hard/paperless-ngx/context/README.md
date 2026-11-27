# Context: paperless-ngx

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/paperless-ngx/values.yaml + Chart.yaml | truecharts-paperless-ngx.md |
| https://hub.docker.com/v2/repositories/apache/tika/ (+ tags?page_size=10) | dockerhub-apache-tika.md |
| https://hub.docker.com/v2/repositories/gotenberg/gotenberg/ (+ tags?page_size=10) | dockerhub-gotenberg.md |
| https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/v3.5.1/Dockerfile | paperless-ngx-dockerfile-v3.5.1.md |
| https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/v3.5.1/docs/configuration.md | paperless-ngx-configuration-v3.5.1.md |
| https://github.com/paperless-ngx/paperless-ngx/releases/latest (alt for API 403) | paperless-ngx-release-latest.md |
| https://paperless-ngx.readthedocs.io/en/latest | paperless-ngx-readthedocs.md |

Skipped: https://api.github.com/repos/paperless-ngx/paperless-ngx/releases/latest (see failures); https://github.com/paperless-ngx/builder/releases (jbig2enc deb source, not fetched; named in Dockerfile); https://github.com/paperless-ngx/paperless-ngx (repo root, covered by raw); https://github.com/paperless-ngx/paperless-ngx/blob/v3.5.1/Dockerfile (duplicate of raw); https://github.com/paperless-ngx/paperless-ngx/tree/dev/docs (not fetched; budget).

Failures:
- https://api.github.com/repos/paperless-ngx/paperless-ngx/releases/latest: HTTP 403; alternative used.

## plan.md corrections
- No edit made. Confirmed: upstream Dockerfile matches plan.md (stages, ENTRYPOINT /init, VOLUME paths /usr/src/paperless/*, EXPOSE 8000); plan.md line 15 said the Dockerfile was read via WebFetch summary, now verbatim.
- Confirmed: plan.md line 19 port 8000/tcp matches by Dockerfile EXPOSE and chart targetPort 8000.
- Note (design, not an error): chart uses PAPERLESS_DATA_DIR=/data and PAPERLESS_MEDIA_ROOT=/media; plan.md maps to /config/data and /config/media.
