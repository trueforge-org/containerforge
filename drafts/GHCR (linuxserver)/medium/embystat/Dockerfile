FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH

ENV HOME=/config \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1

USER root

# download the self-contained upstream build for the target architecture
# NOTE: the sha256 values are local pins (upstream publishes no checksum); re-pin when VERSION changes
# NOTE: unzip exits non-zero on backslash-named entries in the zip, so failures are tolerated
RUN case "${TARGETARCH}" in \
      amd64) asset="EmbyStat-ubuntu-x64-v${VERSION}.zip"; sha="02b7cb09a608ce89ece0c9236f4215ca24936dfa46def9edcdba3263499d94c2" ;; \
      arm64) asset="EmbyStat-linux-arm-x64-v${VERSION}.zip"; sha="e7b09c9ad610f54325e7efb8ae06a61d368a452b51dd4760a27dfeef810e46f2" ;; \
      *) echo "unsupported arch ${TARGETARCH}" && exit 1 ;; \
    esac \
 && curl -fsSL -o /tmp/embystat.zip \
      "https://github.com/mregni/EmbyStat/releases/download/${VERSION}/${asset}" \
 && echo "${sha}  /tmp/embystat.zip" | sha256sum -c - \
 && mkdir -p /app/embystat \
 && (unzip -q /tmp/embystat.zip -d /app/embystat || true) \
 && test -f /app/embystat/EmbyStat \
 && test -f /app/embystat/EmbyStat.runtimeconfig.json \
 && chmod 0755 /app/embystat/EmbyStat \
 \
 # license (MIT per GitHub API; UNVERIFIED that LICENSE exists at the tag)
 && mkdir -p /usr/share/licenses/embystat \
 && curl -fsSL -o /usr/share/licenses/embystat/LICENSE \
      "https://raw.githubusercontent.com/mregni/EmbyStat/${VERSION}/LICENSE" \
 \
 # permissions and cleanup
 && chown -R root:root /app/embystat /usr/share/licenses/embystat \
 && chmod -R 755 /app/embystat \
 && rm -rf /tmp/*

# run as 568
USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 6555
VOLUME ["/config"]
