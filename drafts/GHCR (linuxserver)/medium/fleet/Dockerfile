# NOTE: digest taken from apps/nzbhydra2/Dockerfile as it is in the repo today.
# The plan cited 74b81362..., which does not match the repo.
FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:efdc903d9ce0436b6207bc5a4e732d24a27231851975c999770fd8709a8316b8

ARG VERSION
# Our own pin of the release jar (no upstream checksum). Keep in step with VERSION.
ARG FLEET_SHA256="fa9e6cbaa796a41366c85e36507ff4a287d322c4907f792e9eaeb8b6acf0507a"

ENV fleet_database_driver="org.mariadb.jdbc.Driver" \
    fleet_app_port=8080 \
    fleet_admin_authentication_type=DATABASE

USER root

# UNVERIFIED: the LICENSE file may not exist at the 2.3.3 tag.
RUN mkdir -p /app/fleet /usr/share/licenses/fleet \
 && curl -fsSL -o /app/fleet/fleet.jar \
      "https://github.com/linuxserver/fleet/releases/download/${VERSION}/fleet-${VERSION}.jar" \
 && echo "${FLEET_SHA256}  /app/fleet/fleet.jar" | sha256sum -c - \
 && curl -fsSL -o /usr/share/licenses/fleet/LICENSE \
      "https://raw.githubusercontent.com/linuxserver/fleet/${VERSION}/LICENSE" \
 && chown -R root:root /app/fleet /usr/share/licenses/fleet \
 && chmod -R 755 /app/fleet /usr/share/licenses/fleet \
 && rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 8080
VOLUME /config
