FROM ghcr.io/trueforge-org/python:3.14.7@sha256:74252ae048ecabddaafe9eeb2cd08f8c9ea9ee0c09458a0f41c93d170d6ea9da

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/tmp/nodehome

COPY --from=ghcr.io/trueforge-org/node:24.19.0@sha256:225eb6fc544ed2a7e052fc90395181505b118b0a0c5547b18e1b0207937843ba /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:24.19.0@sha256:225eb6fc544ed2a7e052fc90395181505b118b0a0c5547b18e1b0207937843ba /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:24.19.0@sha256:225eb6fc544ed2a7e052fc90395181505b118b0a0c5547b18e1b0207937843ba /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:24.19.0@sha256:225eb6fc544ed2a7e052fc90395181505b118b0a0c5547b18e1b0207937843ba /opt/ /opthold/

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
