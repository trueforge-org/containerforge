FROM ghcr.io/trueforge-org/python:3.13.7@sha256:28879e692c9ef5264f2bc23dc0cb2ff1402c276b2126309e00eb097ee5ebc1a1

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/app/nodehome

COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:ddd2e92871c2738c4b20cee69e8423049698d6da5f1a9ef910a6acd30e547fed /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:ddd2e92871c2738c4b20cee69e8423049698d6da5f1a9ef910a6acd30e547fed /usr/local/bin/npm /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:ddd2e92871c2738c4b20cee69e8423049698d6da5f1a9ef910a6acd30e547fed /usr/local/bin/npx /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:ddd2e92871c2738c4b20cee69e8423049698d6da5f1a9ef910a6acd30e547fed /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:ddd2e92871c2738c4b20cee69e8423049698d6da5f1a9ef910a6acd30e547fed /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:ddd2e92871c2738c4b20cee69e8423049698d6da5f1a9ef910a6acd30e547fed /opt/ /opthold/

RUN YARN_VERSION=$(cat /YARN_VERSION.txt) && \
    mv /opthold/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm -rf /opthold/

CMD [ "node" ]
