FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/tmp/nodehome

COPY --from=ghcr.io/trueforge-org/node:24.22.0@sha256:b395d720cdb6414b24f023a8ab796f0506644f02c792ca452990d5f05b9db2fd /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:24.22.0@sha256:b395d720cdb6414b24f023a8ab796f0506644f02c792ca452990d5f05b9db2fd /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:24.22.0@sha256:b395d720cdb6414b24f023a8ab796f0506644f02c792ca452990d5f05b9db2fd /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:24.22.0@sha256:b395d720cdb6414b24f023a8ab796f0506644f02c792ca452990d5f05b9db2fd /opt/ /opthold/

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
