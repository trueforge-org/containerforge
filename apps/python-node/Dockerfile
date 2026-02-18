FROM ghcr.io/trueforge-org/python:3.13.12@sha256:911cc57981370bafe55e08ba7d6e209d088a6a15f92fceacaee52fcc17226458

ARG VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV HOME=/tmp/nodehome

COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:c33b4f5d240fa3273f3a5181a59d9c69e0f9e00124306fecfac68bd243ad8c34 /usr/local/bin/node /usr/local/bin/
COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:c33b4f5d240fa3273f3a5181a59d9c69e0f9e00124306fecfac68bd243ad8c34 /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:c33b4f5d240fa3273f3a5181a59d9c69e0f9e00124306fecfac68bd243ad8c34 /YARN_VERSION.txt /YARN_VERSION.txt
COPY --from=ghcr.io/trueforge-org/node:22.22.0@sha256:c33b4f5d240fa3273f3a5181a59d9c69e0f9e00124306fecfac68bd243ad8c34 /opt/ /opthold/

RUN YARN_VERSION=$(cat /YARN_VERSION.txt) && \
    ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
    mv /opthold/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm -rf /opthold/

USER apps

CMD [ "node" ]
