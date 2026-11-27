# Build from source with the .NET SDK from the Ubuntu archive. No .NET base exists in ContainerForge.
# UNVERIFIED: the apt package strings below come from a sibling plan. Re-check on packages.ubuntu.com before merge.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

ARG VERSION
ARG DOTNET_SDK_PACKAGE_VERSION=10.0.114-0ubuntu1~26.04.1

USER root

ENV DOTNET_CLI_HOME=/tmp \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1 \
    NUGET_PACKAGES=/tmp/nuget

# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        "dotnet-sdk-10.0=${DOTNET_SDK_PACKAGE_VERSION}" \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# No checksum is published for the GitHub tag archive. The tag pins the source.
RUN mkdir -p /tmp/src /tmp/publish && \
    curl -fsSL -o /tmp/reflector.tar.gz "https://github.com/emberstack/kubernetes-reflector/archive/refs/tags/v${VERSION}.tar.gz" && \
    tar xzf /tmp/reflector.tar.gz -C /tmp/src --strip-components=1 && \
    rm -f /tmp/reflector.tar.gz && \
    dotnet publish /tmp/src/src/ES.Kubernetes.Reflector/ES.Kubernetes.Reflector.csproj \
        -c Release -o /tmp/publish /p:UseAppHost=false

# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG DOTNET_RUNTIME_PACKAGE_VERSION=10.0.14-0ubuntu1~26.04.1

USER root

# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        "aspnetcore-runtime-10.0=${DOTNET_RUNTIME_PACKAGE_VERSION}" \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build /tmp/publish/ /app/
# UNVERIFIED: the license file name in the upstream tree. Check that LICENSE exists at the tag.
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/kubernetes-reflector/LICENSE

COPY --chmod=0755 . /

# ASP.NET data protection keys default to the home directory, so keep them in /tmp (ephemeral).
ENV HOME=/tmp TZ=Etc/UTC

USER apps

WORKDIR /app
EXPOSE 8080

ENTRYPOINT ["dotnet", "ES.Kubernetes.Reflector.dll"]
