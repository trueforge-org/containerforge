# diamkil/docker-notea Dockerfile (third-party wrapper)

Source URL(s): https://github.com/diamkil/docker-notea/blob/2dd83549e7ca50311c17b24d0b9900b26193392d/Dockerfile (raw variant fetched) · fetched 2026-11-26

## Dockerfile (multi-stage)
- Stage `notea`: `FROM cinwell/notea AS notea`, RUN echo only.
- Stage `minio`: `FROM minio/minio AS minio`, RUN echo only.
- Final: `FROM node:alpine`.
  - `COPY --from=minio /opt/bin/minio /bin/minio`
  - `COPY --from=notea /app/public /notea/public`
  - `COPY --from=notea /app/.next /notea/.next`
  - `COPY --from=notea /app/node_modules /notea/node_modules`
  - `RUN apk add --update curl ca-certificates supervisor bash`
  - `COPY root/ /` (supervisor config and scripts live in repo `root/`, not shown in Dockerfile)
  - `RUN chmod +x /etc/*-Start.sh /start`
- `EXPOSE 3000 9000`
- `CMD ["/bin/bash", "/start"]`
- No ENV, VOLUME, WORKDIR, USER, ENTRYPOINT.

## Gotchas
- Alpine (musl) base: not portable to Ubuntu-based images as-is.
- Start scripts (`/etc/*-Start.sh`, `/start`, supervisor conf) are in upstream `root/`; contents not fetched (fetch budget: raw file list not accessible from this page).
