FROM ghcr.io/trueforge-org/python:3.14.7@sha256:05a7bc16dd8486cbe36714903407947136771e66de31cf93d562200e8a665def

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/tmp/nodehome

COPY --from=ghcr.io/trueforge-org/node:24.19.0@sha256:9bb5ae18e1e9db98eb0722f353a0f3591dc54c4b3c9d9d90a9720df0ceda0255 /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:24.19.0@sha256:9bb5ae18e1e9db98eb0722f353a0f3591dc54c4b3c9d9d90a9720df0ceda0255 /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:24.19.0@sha256:9bb5ae18e1e9db98eb0722f353a0f3591dc54c4b3c9d9d90a9720df0ceda0255 /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:24.19.0@sha256:9bb5ae18e1e9db98eb0722f353a0f3591dc54c4b3c9d9d90a9720df0ceda0255 /opt/ /opthold/

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
