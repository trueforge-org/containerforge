FROM ghcr.io/trueforge-org/python:3.14.7@sha256:d534b660443e3e193750ab98d30402ce6c0de64cbbfe54862aecac1f2ceae18e

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/tmp/nodehome

COPY --from=ghcr.io/trueforge-org/node:24.21.0@sha256:bf1dd21596188c3e2c7731be37699100bc9db0ae0a5384d24f8bcd1afce81665 /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:24.21.0@sha256:bf1dd21596188c3e2c7731be37699100bc9db0ae0a5384d24f8bcd1afce81665 /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:24.21.0@sha256:bf1dd21596188c3e2c7731be37699100bc9db0ae0a5384d24f8bcd1afce81665 /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:24.21.0@sha256:bf1dd21596188c3e2c7731be37699100bc9db0ae0a5384d24f8bcd1afce81665 /opt/ /opthold/

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
