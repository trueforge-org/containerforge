FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG NPVR_SHA256

USER root

# UNVERIFIED: package names on Ubuntu 26.04 (libcurl4t64, libssl3t64, libmediainfo0v5, libdvbv5-0, dtv-scan-tables).
# Drop the DVB packages if only network tuners are supported.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        acl \
        ca-certificates \
        curl \
        dtv-scan-tables \
        dvb-tools \
        ffmpeg \
        libcurl4t64 \
        libdvbv5-0 \
        libgdiplus \
        libmediainfo0v5 \
        libssl3t64 \
        mediainfo \
        unzip \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# UNVERIFIED: the .NET 8 ASP.NET Core runtime is not confirmed for Ubuntu 26.04. Replace with a verified
# install (apt package, or dotnet-install.sh with a checksum) if this package does not exist.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends aspnetcore-runtime-8.0 && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# The zip URL has no version and changes with each upstream release. NPVR_SHA256 must be bumped by hand.
RUN curl -fL -o /tmp/NPVR.zip "http://nextpvr.com/stable/linux/NPVR.zip" && \
    echo "${NPVR_SHA256}  /tmp/NPVR.zip" | sha256sum -c - && \
    install -d /app/nextpvr && \
    unzip -q /tmp/NPVR.zip -d /app/nextpvr && \
    rm -f /tmp/NPVR.zip && \
    install -D /app/nextpvr/LICENSE.txt /usr/share/licenses/nextpvr/LICENSE.txt

ENV HOME=/config \
    DOTNET_CLI_HOME=/tmp/dotnet \
    DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet-bundle \
    DOTNET_EnableDiagnostics=0

USER apps
COPY --chmod=0755 . /

EXPOSE 8866
EXPOSE 16891/udp

VOLUME /config

CMD ["/start.sh"]
