FROM ghcr.io/trueforge-org/python:3.13.12@sha256:d9b5d12c8e22d9b84df211da15c73e7e2b36441675f00bba2c706f93526c602b

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/tmp/nodehome

COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:b003160352643fa8b3341f2550c484d1ec754078df700f7a87948584e0a5939c /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:b003160352643fa8b3341f2550c484d1ec754078df700f7a87948584e0a5939c /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:b003160352643fa8b3341f2550c484d1ec754078df700f7a87948584e0a5939c /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:b003160352643fa8b3341f2550c484d1ec754078df700f7a87948584e0a5939c /opt/ /opthold/

RUN YARN_VERSION=$(cat /YARN_VERSION.txt) && \
    ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
    mv /opthold/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm -rf /opthold/

USER apps

CMD [ "node" ]
