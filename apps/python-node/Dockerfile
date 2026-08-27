FROM ghcr.io/trueforge-org/python:3.14.6@sha256:7126ada2ea0c2086b0f078af562c413bbbbb44b946aeb70c3175386647e434fe

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/tmp/nodehome

COPY --from=ghcr.io/trueforge-org/node:24.20.0@sha256:8b156cec6a8d95ad3b89839bce1925c92bde775efd5043229371031a5c4c3c32 /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:24.20.0@sha256:8b156cec6a8d95ad3b89839bce1925c92bde775efd5043229371031a5c4c3c32 /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:24.20.0@sha256:8b156cec6a8d95ad3b89839bce1925c92bde775efd5043229371031a5c4c3c32 /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:24.20.0@sha256:8b156cec6a8d95ad3b89839bce1925c92bde775efd5043229371031a5c4c3c32 /opt/ /opthold/

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
