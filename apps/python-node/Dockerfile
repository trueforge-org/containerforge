FROM ghcr.io/trueforge-org/python:3.13.12@sha256:cac0b51ee72888e75bf2ff4ae1a46be0b5310663584fc54d621d0476e573f5b8

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/tmp/nodehome

COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:e03554fe5a09fa1914bbd02478cc590f1520bd0de4972529b226f430f6d0b84c /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:e03554fe5a09fa1914bbd02478cc590f1520bd0de4972529b226f430f6d0b84c /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:e03554fe5a09fa1914bbd02478cc590f1520bd0de4972529b226f430f6d0b84c /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:e03554fe5a09fa1914bbd02478cc590f1520bd0de4972529b226f430f6d0b84c /opt/ /opthold/

RUN YARN_VERSION=$(cat /YARN_VERSION.txt) && \
    ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
    mv /opthold/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm -rf /opthold/

USER apps

CMD [ "node" ]
