FROM ghcr.io/trueforge-org/python:3.13.7@sha256:be294e0b693a9c982bd5d5f14c18b7181326eb9f47f2d05c4f8a0c2cc58b6709

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/app/nodehome

COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:e7943f0fd226d9a2db62d2a65612ee5f9c95528661913f546ab15fc08d53ccab /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:e7943f0fd226d9a2db62d2a65612ee5f9c95528661913f546ab15fc08d53ccab /usr/local/bin/npm /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:e7943f0fd226d9a2db62d2a65612ee5f9c95528661913f546ab15fc08d53ccab /usr/local/bin/npx /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:e7943f0fd226d9a2db62d2a65612ee5f9c95528661913f546ab15fc08d53ccab /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:e7943f0fd226d9a2db62d2a65612ee5f9c95528661913f546ab15fc08d53ccab /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:e7943f0fd226d9a2db62d2a65612ee5f9c95528661913f546ab15fc08d53ccab /opt/ /opthold/

RUN YARN_VERSION=$(cat /YARN_VERSION.txt) && \
    mv /opthold/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm -rf /opthold/

CMD [ "node" ]
