FROM ghcr.io/trueforge-org/python:3.13.12@sha256:3ba383a203ccb7bca70a25d7a34d422dd3ab48053023dd3ca67f51bca3ef3955

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/app/nodehome

COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:3c3a3dc7f96d36e986d4f6b5352fc77ed9b334bf0acadf64aab31da483e40122 /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:3c3a3dc7f96d36e986d4f6b5352fc77ed9b334bf0acadf64aab31da483e40122 /usr/local/bin/npm /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:3c3a3dc7f96d36e986d4f6b5352fc77ed9b334bf0acadf64aab31da483e40122 /usr/local/bin/npx /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:3c3a3dc7f96d36e986d4f6b5352fc77ed9b334bf0acadf64aab31da483e40122 /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:3c3a3dc7f96d36e986d4f6b5352fc77ed9b334bf0acadf64aab31da483e40122 /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:3c3a3dc7f96d36e986d4f6b5352fc77ed9b334bf0acadf64aab31da483e40122 /opt/ /opthold/

RUN YARN_VERSION=$(cat /YARN_VERSION.txt) && \
    mv /opthold/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm -rf /opthold/

CMD [ "node" ]
