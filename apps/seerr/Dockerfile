
ARG VERSION
FROM fallenbagel/jellyseerr:$VERSION AS base

FROM ghcr.io/trueforge-org/node:22.20@sha256:c57ff53b69edd1f3aae2d6e00ad2da65606b5dbc1fb42c78b4a73b44e58d099d

USER apps:apps

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --chmod=0775 . /

ARG SOURCE_DATE_EPOCH
ARG COMMIT_TAG
ENV NODE_ENV=production

WORKDIR /app

COPY --chown=apps:apps --from=base /app .

EXPOSE 5055

CMD [ "npm", "start" ]
