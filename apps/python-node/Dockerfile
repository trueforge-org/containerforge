FROM ghcr.io/trueforge-org/python:3.13.7@sha256:cbb27d8be6746edc1ba1b6abc502a3ce311948e4e9025c73b7dee50c6a1bbd0d

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/app/nodehome

COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:faab5a63db1426eff0e065ab6635c739155986e89b248f1fd160babcd2c6fbe0 /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:faab5a63db1426eff0e065ab6635c739155986e89b248f1fd160babcd2c6fbe0 /usr/local/bin/npm /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:faab5a63db1426eff0e065ab6635c739155986e89b248f1fd160babcd2c6fbe0 /usr/local/bin/npx /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:faab5a63db1426eff0e065ab6635c739155986e89b248f1fd160babcd2c6fbe0 /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:faab5a63db1426eff0e065ab6635c739155986e89b248f1fd160babcd2c6fbe0 /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:faab5a63db1426eff0e065ab6635c739155986e89b248f1fd160babcd2c6fbe0 /opt/ /opthold/

RUN YARN_VERSION=$(cat /YARN_VERSION.txt) && \
    mv /opthold/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm -rf /opthold/

CMD [ "node" ]
