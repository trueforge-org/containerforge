FROM ghcr.io/trueforge-org/python:3.13.7@sha256:3664bd10fe22328f1b7d6d1002a074b6bbfc78b7688200388230f49190d622e2

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/app/nodehome

COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:0d7011c0cfa0d010fa93c711ed870c7bc88a26588ef040629132939dd6816097 /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:0d7011c0cfa0d010fa93c711ed870c7bc88a26588ef040629132939dd6816097 /usr/local/bin/npm /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:0d7011c0cfa0d010fa93c711ed870c7bc88a26588ef040629132939dd6816097 /usr/local/bin/npx /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:0d7011c0cfa0d010fa93c711ed870c7bc88a26588ef040629132939dd6816097 /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:0d7011c0cfa0d010fa93c711ed870c7bc88a26588ef040629132939dd6816097 /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:0d7011c0cfa0d010fa93c711ed870c7bc88a26588ef040629132939dd6816097 /opt/ /opthold/

RUN YARN_VERSION=$(cat /YARN_VERSION.txt) && \
    mv /opthold/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm -rf /opthold/

CMD [ "node" ]
