FROM ghcr.io/trueforge-org/python:3.13.12@sha256:77449580f12ca47641798a11e38291c1e30b532818ea7809078c3fa6e9bfc4df

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/app/nodehome

COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:3345d6d3e3fb826b171518a83172dad4f4fc7f248933606daf72ed517053e693 /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:3345d6d3e3fb826b171518a83172dad4f4fc7f248933606daf72ed517053e693 /usr/local/bin/npm /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:3345d6d3e3fb826b171518a83172dad4f4fc7f248933606daf72ed517053e693 /usr/local/bin/npx /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:3345d6d3e3fb826b171518a83172dad4f4fc7f248933606daf72ed517053e693 /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:3345d6d3e3fb826b171518a83172dad4f4fc7f248933606daf72ed517053e693 /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:3345d6d3e3fb826b171518a83172dad4f4fc7f248933606daf72ed517053e693 /opt/ /opthold/

RUN YARN_VERSION=$(cat /YARN_VERSION.txt) && \
    mv /opthold/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm -rf /opthold/

CMD [ "node" ]
