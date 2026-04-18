FROM ghcr.io/trueforge-org/python:3.14.4@sha256:ad4dde9774b3433fdfd16a118973b00ebf41d716d9f8e666cc34c8e30c168c56

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/tmp/nodehome

COPY --from=ghcr.io/trueforge-org/node:22.22.1@sha256:f3730b32628892a22dfa85e96750e83ab5f3e85c6170915e19110c134ab649e8 /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.22.1@sha256:f3730b32628892a22dfa85e96750e83ab5f3e85c6170915e19110c134ab649e8 /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:22.22.1@sha256:f3730b32628892a22dfa85e96750e83ab5f3e85c6170915e19110c134ab649e8 /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:22.22.1@sha256:f3730b32628892a22dfa85e96750e83ab5f3e85c6170915e19110c134ab649e8 /opt/ /opthold/

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
