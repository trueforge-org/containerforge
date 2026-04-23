FROM ghcr.io/trueforge-org/python:3.13.13@sha256:d90e00c1ba6abf16c8d68d5e898657109371cd601270e3a3ae5b32782fe1cc15

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/tmp/nodehome

COPY --from=ghcr.io/trueforge-org/node:24.15.0@sha256:c418ccbc52ef7d2aef66ad3df778138d668c2bd612030f897f5f5f1081b8a2c6 /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:24.15.0@sha256:c418ccbc52ef7d2aef66ad3df778138d668c2bd612030f897f5f5f1081b8a2c6 /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:24.15.0@sha256:c418ccbc52ef7d2aef66ad3df778138d668c2bd612030f897f5f5f1081b8a2c6 /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:24.15.0@sha256:c418ccbc52ef7d2aef66ad3df778138d668c2bd612030f897f5f5f1081b8a2c6 /opt/ /opthold/

RUN YARN_VERSION=$(cat /YARN_VERSION.txt) && \
    ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
    mv /opthold/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm -rf /opthold/

USER apps
COPY --chmod=0755 . /

CMD [ "node" ]
