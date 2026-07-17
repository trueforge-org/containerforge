FROM ghcr.io/trueforge-org/python:3.14.6@sha256:0859da470a5092cf1bdec06d87165ec6eebd7d490682b89035f450db869223fb

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/tmp/nodehome

COPY --from=ghcr.io/trueforge-org/node:24.18.0@sha256:6ec4fab2b7ac2090590b454edf431acec72749608cd3c60990bbad03a19f07ac /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:24.18.0@sha256:6ec4fab2b7ac2090590b454edf431acec72749608cd3c60990bbad03a19f07ac /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:24.18.0@sha256:6ec4fab2b7ac2090590b454edf431acec72749608cd3c60990bbad03a19f07ac /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:24.18.0@sha256:6ec4fab2b7ac2090590b454edf431acec72749608cd3c60990bbad03a19f07ac /opt/ /opthold/

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
