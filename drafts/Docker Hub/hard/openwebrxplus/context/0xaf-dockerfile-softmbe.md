# 0xAF/openwebrxplus-docker-builder buildfiles/Dockerfile-softmbe

Source URL(s): https://github.com/0xAF/openwebrxplus-docker-builder/blob/3ead881/buildfiles/Dockerfile-softmbe (raw fetched at 3ead881) · fetched 2026-11-26

## Stage 1 `build`
- `FROM debian:bookworm-slim AS build`.
- ARG MAKEFLAGS (no default); ARG USE_LEGACY_MBELIB=n.
- COPY build-softmbe-packages.sh, common.sh, prepare-mbelib-neo-debian.sh -> /; COPY files/mbelib-neo-debian -> /mbelib-neo-debian.
- RUN with BuildKit cache mount `owrxp-buildcache-softmbe` at /build_cache: runs /build-softmbe-packages.sh with USE_LEGACY_MBELIB; deletes the two build scripts afterwards.
- apt/URL/pin details are inside the scripts (not fetched).

## Stage 2 (final)
- `FROM slechev/openwebrxplus:latest` (unpinned, so SoftMBE image sits on the standard image).
- ARG ARCH, MAKEFLAGS.
- COPY --from=build /deb -> /deb; COPY install-softmbe-packages.sh -> /; RUN it, then remove it.
- WORKDIR /; ENTRYPOINT ["/init"] (s6 init); VOLUME /etc/openwebrx and /var/lib/openwebrx; EXPOSE 8073.
- Commented out: S6_CMD_ARG0=/opt/openwebrx/docker/scripts/run.sh, WORKDIR /opt/openwebrx, CMD [].
- No USER, HEALTHCHECK, ADD, active ENV.
