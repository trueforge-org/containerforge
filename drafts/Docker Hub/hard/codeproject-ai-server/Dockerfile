
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
ARG CPAI_SHA256_AMD64
ARG CPAI_SHA256_ARM64
USER root

ENV HOME=/config \
    DOTNET_ROOT=/app/dotnet \
    PATH=/app/dotnet:$PATH \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    PIP_CACHE_DIR=/tmp/pip

# UNVERIFIED (inferred): libs needed by the vision modules (OpenCV, torch wheels). Drop what the first run does not need.
RUN echo "*** Installing system packages ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    libgomp1 \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 && \
  rm -rf /var/lib/apt/lists/*

# ASP.NET Core runtime (aspnetcore, not just dotnet: the server needs Microsoft.AspNetCore.App).
# UNVERIFIED: dot.net install script is not pinned to a checksum.
RUN echo "*** Installing .NET 9 ASP.NET Core runtime ***" && \
  mkdir -p /app/dotnet && \
  curl -fsSL -o /tmp/dotnet-install.sh https://dot.net/v1/dotnet-install.sh && \
  chmod +x /tmp/dotnet-install.sh && \
  /tmp/dotnet-install.sh -c 9.0 --install-dir /app/dotnet --runtime aspnetcore && \
  rm -f /tmp/dotnet-install.sh

# The vendor .deb is unpacked, not installed: its postinst runs setup.sh, which expects systemd and root.
RUN echo "*** Installing CodeProject.AI Server ***" && \
  cpai_ver="${VERSION#v}" && \
  case "${TARGETARCH}" in \
    amd64) arch=x64; sha="${CPAI_SHA256_AMD64}" ;; \
    arm64) arch=arm64; sha="${CPAI_SHA256_ARM64}" ;; \
    *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fsSL -o /tmp/cpai.zip \
    "https://codeproject-ai-bunny.b-cdn.net/server/installers/linux/codeproject.ai-server_${cpai_ver}_Ubuntu_${arch}.zip" && \
  echo "${sha}  /tmp/cpai.zip" | sha256sum -c - && \
  mkdir -p /tmp/cpai-zip /tmp/cpai /app/server && \
  unzip -q /tmp/cpai.zip -d /tmp/cpai-zip && \
  dpkg-deb -x /tmp/cpai-zip/*.deb /tmp/cpai && \
  cp -a "/tmp/cpai/usr/bin/codeproject.ai-server-${cpai_ver}/." /app/server/ && \
  echo "*** Installing license and settings link ***" && \
  mkdir -p /usr/share/licenses/codeproject-ai-server /etc/codeproject && \
  cp /app/server/LICENCE.md /usr/share/licenses/codeproject-ai-server/LICENCE.md && \
  ln -s /config/settings /etc/codeproject/ai && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /


EXPOSE 32168

VOLUME /config

WORKDIR /app/server
CMD ["/start.sh"]
