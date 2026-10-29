FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/tmp/nodehome

COPY --from=ghcr.io/trueforge-org/node:24.22.2@sha256:ac184e4789c9d75d84a60bafc4ce892a1fbfbaca29bbd5d9303d74120664d283 /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:24.22.2@sha256:ac184e4789c9d75d84a60bafc4ce892a1fbfbaca29bbd5d9303d74120664d283 /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:24.22.2@sha256:ac184e4789c9d75d84a60bafc4ce892a1fbfbaca29bbd5d9303d74120664d283 /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:24.22.2@sha256:ac184e4789c9d75d84a60bafc4ce892a1fbfbaca29bbd5d9303d74120664d283 /opt/ /opthold/

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
