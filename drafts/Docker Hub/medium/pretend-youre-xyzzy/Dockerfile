
# Build stage: compile the WAR from the upstream source at a pinned commit.
# UNVERIFIED: the project's Java target. The java17 base is used (plan option B); the java11 option has no verified tag or digest in this repo.
FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:efdc903d9ce0436b6207bc5a4e732d24a27231851975c999770fd8709a8316b8 AS build

# git commit SHA of ajanata/PretendYoureXyzzy (archived upstream, no releases)
ARG VERSION
ARG MAVEN_VERSION=3.9.6

RUN mkdir -p /tmp/maven /tmp/src \
 # Maven, verified against the SHA-512 published by Apache
 && curl -fsSL -o /tmp/maven.tgz \
      "https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" \
 && curl -fsSL -o /tmp/maven.tgz.sha512 \
      "https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz.sha512" \
 && echo "$(awk '{print $1}' /tmp/maven.tgz.sha512)  /tmp/maven.tgz" | sha512sum -c - \
 && tar -xzf /tmp/maven.tgz -C /tmp/maven --strip-components=1 \
 \
 # upstream source at the pinned commit
 && curl -fsSL -o /tmp/src.tgz "https://github.com/ajanata/PretendYoureXyzzy/archive/${VERSION}.tar.gz" \
 && tar -xzf /tmp/src.tgz -C /tmp/src --strip-components=1 \
 && rm -f /tmp/maven.tgz /tmp/maven.tgz.sha512 /tmp/src.tgz

WORKDIR /tmp/src

# same flags as the upstream packaging image's builder stage
RUN cp build.properties.example build.properties \
 && HOME=/tmp PATH="/tmp/maven/bin:${PATH}" mvn -B compile war:war \
      -Dhttps.protocols=TLSv1.2 \
      -Dmaven.buildNumber.doCheck=false \
      -Dmaven.buildNumber.doUpdate=false

# Runtime stage
FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:efdc903d9ce0436b6207bc5a4e732d24a27231851975c999770fd8709a8316b8

# Tomcat 10.1, the line the upstream packaging image uses
# UNVERIFIED: the upstream README says only Tomcat 7 is known to work; confirm by running the WAR
ARG TOMCAT_VERSION=10.1.17

USER root

RUN mkdir -p /app/tomcat /app/war /tmp/tomcat-dl \
 # Tomcat, verified against the SHA-512 published by Apache
 && curl -fsSL -o /tmp/tomcat-dl/tomcat.tgz \
      "https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
 && curl -fsSL -o /tmp/tomcat-dl/tomcat.tgz.sha512 \
      "https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz.sha512" \
 && echo "$(awk '{print $1}' /tmp/tomcat-dl/tomcat.tgz.sha512)  /tmp/tomcat-dl/tomcat.tgz" | sha512sum -c - \
 && tar -xzf /tmp/tomcat-dl/tomcat.tgz -C /app/tomcat --strip-components=1 \
 # only ROOT is deployed; drop the bundled sample apps
 && rm -rf /app/tomcat/webapps/* \
 && rm -rf /tmp/tomcat-dl \
 && chown -R root:root /app \
 && chmod -R 755 /app

COPY --from=build /tmp/src/target/ZY.war /app/war/ROOT.war

# UNVERIFIED: the license is in WebContent/license.html per the upstream README; confirm the path
COPY --from=build /tmp/src/WebContent/license.html /usr/share/licenses/pretend-youre-xyzzy/license.html

# run as 568
USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME ["/config"]

EXPOSE 8080/tcp
