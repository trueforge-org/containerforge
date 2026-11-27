FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

# renovate: datasource=git-tags depName=https://github.com/OperatorFoundation/shapeshifter-dispatcher versioning=semver
ARG VERSION=3.0.1
ARG TARGETARCH

USER root

# Go comes from the ubuntu base (same approach as apps/gluetun). UNVERIFIED: the base Go must satisfy the go directive in go.mod at v3.0.1.
# Build caches go to /tmp, never to /config or /app.
ENV GOCACHE=/tmp/go-cache \
    GOPATH=/tmp/go

# Fetch the tagged source and fail the build if the tag does not resolve to the expected commit.
# The commit must be updated together with VERSION (tag v3.0.1 = 401e1869e211f3dfbf627cd5e4d327ad3f91ea67).
RUN set -eux; \
    git clone --depth 1 --branch "v${VERSION}" \
        https://github.com/OperatorFoundation/shapeshifter-dispatcher /src/shapeshifter-dispatcher; \
    test "$(git -C /src/shapeshifter-dispatcher rev-parse HEAD)" = "401e1869e211f3dfbf627cd5e4d327ad3f91ea67"

# UNVERIFIED: main package assumed at the repo root, as the upstream Dockerfile builds it (go build && go install).
RUN set -eux; \
    cd /src/shapeshifter-dispatcher; \
    CGO_ENABLED=0 GOARCH="${TARGETARCH}" go build -trimpath -ldflags="-s -w" \
        -o /out/shapeshifter-dispatcher .; \
    rm -rf /tmp/go-cache /tmp/go

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
USER root

ENV \
    HOME=/config

COPY --from=build /out/shapeshifter-dispatcher /app/shapeshifter-dispatcher
COPY --from=build /src/shapeshifter-dispatcher/LICENSE /usr/share/licenses/shapeshifter-obfuscator/LICENSE

RUN chown -R root:root /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

# UNVERIFIED: 2222 comes from upstream EXPOSE and the chart. Must match the listener in start.sh.
EXPOSE 2222

VOLUME /config
