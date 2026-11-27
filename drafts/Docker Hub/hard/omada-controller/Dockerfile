FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:efdc903d9ce0436b6207bc5a4e732d24a27231851975c999770fd8709a8316b8

# set version label
ARG VERSION
ARG OMADA_URL
# UNVERIFIED: TP-Link publishes no checksum. Compute sha256 of OMADA_URL once and pin it in docker-bake.hcl and here.
# An empty value makes the sha256sum check fail on purpose, so the build does not run unverified.
ARG OMADA_SHA256=""
ARG MONGODB_VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  TZ=Etc/UTC

# hadolint ignore=DL3008,DL3015,SC2086,DL4006
RUN set -eux; \
    echo "**** install runtime packages and embedded MongoDB ****"; \
    case "${TARGETARCH}" in \
        amd64) mongo_arch=x86_64 ;; \
        arm64) mongo_arch=aarch64 ;; \
        *) echo "Unsupported architecture ${TARGETARCH}"; exit 1 ;; \
    esac; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl libcurl4t64 procps; \
    mongo_url="https://fastdl.mongodb.org/linux/mongodb-linux-${mongo_arch}-ubuntu2404-${MONGODB_VERSION}.tgz"; \
    curl -fsSL -o /tmp/mongodb.tgz "${mongo_url}"; \
    echo "$(curl -fsSL "${mongo_url}.sha256" | cut -d ' ' -f 1)  /tmp/mongodb.tgz" | sha256sum -c -; \
    tar -xzf /tmp/mongodb.tgz -C /usr/local/bin --strip-components=2 --wildcards '*/bin/mongod'; \
    mkdir -p /usr/share/licenses/mongodb; \
    tar -xzf /tmp/mongodb.tgz -C /usr/share/licenses/mongodb --strip-components=1 --wildcards '*/LICENSE-Community.txt' '*/MPL-2' '*/THIRD-PARTY-NOTICES'; \
    mongod --version; \
    echo "**** install Omada Network Application ${VERSION} ****"; \
    curl -fsSL -o /tmp/omada.tgz "${OMADA_URL}"; \
    echo "${OMADA_SHA256}  /tmp/omada.tgz" | sha256sum -c -; \
    mkdir -p /tmp/omada-src /app/omada /usr/share/licenses/omada-controller; \
    tar -xzf /tmp/omada.tgz -C /tmp/omada-src; \
    src="$(echo /tmp/omada-src/Omada_Network_Application_*)"; \
    cp -a "${src}/bin" "${src}/data" "${src}/lib" "${src}/properties" /app/omada/; \
    for f in "${src}"/LICENSE* "${src}"/EULA*; do \
        if [ -f "$f" ]; then cp "$f" /usr/share/licenses/omada-controller/; fi; \
    done; \
    mv /app/omada/properties /app/omada/properties.defaults; \
    tar -czf /app/omada/data-html.tar.gz -C /app/omada/data html; \
    rm -rf /app/omada/data; \
    echo "**** link runtime paths to /config and /tmp (the image filesystem is read-only at runtime) ****"; \
    ln -s /config/data /app/omada/data; \
    ln -s /config/logs /app/omada/logs; \
    ln -s /tmp/omada-work /app/omada/work; \
    chmod 755 /app/omada/bin/*; \
    chown -R root:root /app; \
    chmod -R a+rX /app; \
    echo "**** cleanup ****"; \
    rm -rf /tmp/* /var/lib/apt/lists/*

# copy local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
# UDP ports are used by device discovery and need LAN reachability (host or macvlan networking).
EXPOSE 8043 8088 8843 8044 29811 29812 29813 29814 29815 29816 29817
EXPOSE 19810/udp 27001/udp 29810/udp
VOLUME /config
WORKDIR /config
