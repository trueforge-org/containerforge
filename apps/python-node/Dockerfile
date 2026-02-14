FROM ghcr.io/trueforge-org/python:3.13.7@sha256:708f480d444e56c1b20c0966b9fa08ce0aaba16ed5e2ef3469f5f6a161549e87

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/app/nodehome

COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:57a1af013f040f6d66a0d1b53cc48dc6ac8b603c1384639fb3c4fe27252baf34 /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:57a1af013f040f6d66a0d1b53cc48dc6ac8b603c1384639fb3c4fe27252baf34 /usr/local/bin/npm /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:57a1af013f040f6d66a0d1b53cc48dc6ac8b603c1384639fb3c4fe27252baf34 /usr/local/bin/npx /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:57a1af013f040f6d66a0d1b53cc48dc6ac8b603c1384639fb3c4fe27252baf34 /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:57a1af013f040f6d66a0d1b53cc48dc6ac8b603c1384639fb3c4fe27252baf34 /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:57a1af013f040f6d66a0d1b53cc48dc6ac8b603c1384639fb3c4fe27252baf34 /opt/ /opthold/

RUN YARN_VERSION=$(cat /YARN_VERSION.txt) && \
    mv /opthold/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm -rf /opthold/

CMD [ "node" ]
