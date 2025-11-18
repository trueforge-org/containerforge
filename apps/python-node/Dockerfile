FROM ghcr.io/trueforge-org/python:3.13.7@sha256:8a2c1da075925eac6d7e3a405035b60a68e1f82cf61b7807a7e87d9ca4f8c999

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/app/nodehome

COPY --from=ghcr.io/trueforge-org/node:22.20.0 /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0 /usr/local/bin/npm /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0 /usr/local/bin/npx /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0 /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:22.20.0 /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:22.20.0 /opt/ /opthold/

RUN YARN_VERSION=$(cat /YARN_VERSION.txt) && \
    mv /opthold/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm -rf /opthold/

CMD [ "node" ]
