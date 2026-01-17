FROM ghcr.io/trueforge-org/python:3.13.7@sha256:cbb27d8be6746edc1ba1b6abc502a3ce311948e4e9025c73b7dee50c6a1bbd0d

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/app/nodehome

COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:6be7812f84693f5cbe26ea547ac358ab925f1edbfe85bf130c5d474a35ad7ad9 /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:6be7812f84693f5cbe26ea547ac358ab925f1edbfe85bf130c5d474a35ad7ad9 /usr/local/bin/npm /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:6be7812f84693f5cbe26ea547ac358ab925f1edbfe85bf130c5d474a35ad7ad9 /usr/local/bin/npx /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:6be7812f84693f5cbe26ea547ac358ab925f1edbfe85bf130c5d474a35ad7ad9 /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:6be7812f84693f5cbe26ea547ac358ab925f1edbfe85bf130c5d474a35ad7ad9 /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:6be7812f84693f5cbe26ea547ac358ab925f1edbfe85bf130c5d474a35ad7ad9 /opt/ /opthold/

RUN YARN_VERSION=$(cat /YARN_VERSION.txt) && \
    mv /opthold/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm -rf /opthold/

CMD [ "node" ]
