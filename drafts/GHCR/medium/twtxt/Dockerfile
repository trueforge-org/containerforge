# UNVERIFIED: golang tag. Check the Docker Hub tag list and the go.mod directive of the pinned twtxt tag before the first build.
FROM golang:1.27@sha256:5f1b98fa02fe396ebce2a0227a0e08309e11792915b9dd2e1f71053d7e7e6666 AS build

ARG VERSION
ARG CHECKSUM

# UNVERIFIED: the GitHub tag archive may not resolve (see plan section 10). The sha256 comes from docker-bake.hcl.
RUN curl -fsSL -o /tmp/src.tar.gz "https://github.com/prologic/twtxt/archive/refs/tags/${VERSION}.tar.gz" \
    && echo "${CHECKSUM}  /tmp/src.tar.gz" | sha256sum -c - \
    && mkdir -p /src \
    && tar -xzf /tmp/src.tar.gz -C /src --strip-components 1 \
    && rm -f /tmp/src.tar.gz

WORKDIR /src
RUN make deps \
    && make server VERSION="${VERSION}" COMMIT=HEAD

# UNVERIFIED: the server needs no apt packages at runtime (ffmpeg not confirmed). Do not add the upstream ffmpeg install without a check.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

COPY --from=build --chmod=0755 /src/twtd /app/twtd
# UNVERIFIED: LICENSE file name in the tag
COPY --from=build /src/LICENSE /usr/share/licenses/twtxt/LICENSE

USER apps
COPY --chmod=0755 . /

EXPOSE 8000

VOLUME /config

CMD ["/start.sh"]
