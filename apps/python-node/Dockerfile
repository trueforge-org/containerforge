FROM ghcr.io/trueforge-org/python:3.13.7@sha256:6119b5ecab933bfd4ceb9c7e56b8c93379b830d6a5af0aa9cb7b014e1078be8f

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/app/nodehome

COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:bc0b3758205bf09f45751164affb9028ddcd246e852a1611b0468a03a2244ea9 /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:bc0b3758205bf09f45751164affb9028ddcd246e852a1611b0468a03a2244ea9 /usr/local/bin/npm /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:bc0b3758205bf09f45751164affb9028ddcd246e852a1611b0468a03a2244ea9 /usr/local/bin/npx /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:bc0b3758205bf09f45751164affb9028ddcd246e852a1611b0468a03a2244ea9 /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:bc0b3758205bf09f45751164affb9028ddcd246e852a1611b0468a03a2244ea9 /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:22.20.0@sha256:bc0b3758205bf09f45751164affb9028ddcd246e852a1611b0468a03a2244ea9 /opt/ /opthold/

RUN YARN_VERSION=$(cat /YARN_VERSION.txt) && \
    mv /opthold/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm -rf /opthold/

CMD [ "node" ]
