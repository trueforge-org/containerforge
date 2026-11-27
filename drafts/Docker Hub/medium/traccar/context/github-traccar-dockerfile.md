# GitHub traccar/traccar docker/Dockerfile.alpine (master)

Source URL(s) + date:
- https://raw.githubusercontent.com/traccar/traccar/master/docker/Dockerfile.alpine
- Fetched 2026-11-27

## Dockerfile
```
FROM alpine AS package
ARG VERSION
COPY traccar-other-$VERSION.zip /tmp/traccar.zip
RUN unzip -qo /tmp/traccar.zip -d /traccar

FROM eclipse-temurin:25-alpine AS jdk
RUN jlink --add-modules java.se,jdk.charsets,jdk.crypto.ec,jdk.net,jdk.unsupported \
    --strip-debug --no-header-files --no-man-pages --compress=2 --output /jre

FROM alpine
COPY --from=package /traccar /opt/traccar
COPY --from=jdk /jre /opt/traccar/jre
WORKDIR /opt/traccar
ENTRYPOINT ["/opt/traccar/jre/bin/java", "-XX:+ExitOnOutOfMemoryError"]
CMD ["-jar", "tracker-server.jar", "conf/traccar.xml"]
```

## Facts
- Input is `traccar-other-$VERSION.zip` (build context file, unzipped to `/opt/traccar`). Same asset works for both arches (JRE is built here).
- Runtime JRE: custom `jlink` image from `eclipse-temurin:25-alpine` with modules java.se, jdk.charsets, jdk.crypto.ec, jdk.net, jdk.unsupported.
- Final base: `alpine`. WORKDIR `/opt/traccar`. Jar `tracker-server.jar`, config `conf/traccar.xml`.
- No EXPOSE, no VOLUME, no USER, no HEALTHCHECK, no ENV in this file (runs as root).

## Gotchas
- The zip is provided by the build context (the upstream Dockerfile does not download it).
- Upstream uses alpine; a Ubuntu base needs a different JRE path.
