FROM ghcr.io/trueforge-org/python:3.14.6@sha256:d68fb2080f1cf876f37992bdb39d84a71ae30f745f4c82b31c06b07d5f4bcad3

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/tmp/nodehome

COPY --from=ghcr.io/trueforge-org/node:24.16.0@sha256:054127dbde86feda9878cd8b6ccef97a4988a3f28f9e40bdc138c70cebb3f2ec /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:24.16.0@sha256:054127dbde86feda9878cd8b6ccef97a4988a3f28f9e40bdc138c70cebb3f2ec /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:24.16.0@sha256:054127dbde86feda9878cd8b6ccef97a4988a3f28f9e40bdc138c70cebb3f2ec /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:24.16.0@sha256:054127dbde86feda9878cd8b6ccef97a4988a3f28f9e40bdc138c70cebb3f2ec /opt/ /opthold/

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
