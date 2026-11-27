# GitHub: Cyb3r-Jak3/DockerYourXyzzy (packaging Dockerfile)

## Source URL(s) + date
- https://raw.githubusercontent.com/Cyb3r-Jak3/DockerYourXyzzy/fade38c9e0b94c1294360a1f4697ab167dbd3d09/Dockerfile
- Fetched 2026-11-27

## Stages
- `base`: `FROM ghcr.io/cyb3r-jak3/alpine-tomcat:11-jdk-10.1.17 as base`.
- `on-demand`: `FROM base`, `WORKDIR /project`.
- `builder`: `FROM base`, `WORKDIR /project`.
- `prebuilt`: `FROM jetty:11-jre11-slim`.

## Install/build steps
- base: `apk add curl tar procps`; Maven `ARG MAVEN_VERSION=3.9.6` downloaded from `https://api.cyberjake.xyz/download_proxy/maven?version=${MAVEN_VERSION}`, verified with `sha512sum` against `ARG SHA`; extracted to `/usr/share/maven`; `ln -s /usr/share/maven/bin/mvn /usr/bin/mvn`.
- on-demand: installs dos2unix and git from Alpine edge community (`--allow-untrusted`), `git clone -b $GIT_BRANCH https://github.com/ajanata/PretendYoureXyzzy.git /project`, `chmod +x /default.sh /overrides.sh`, `mkdir /overrides`.
- builder: `git clone -b $GIT_BRANCH https://github.com/ajanata/PretendYoureXyzzy.git /project`; `mv build.properties.example build.properties`; `mvn compile war:war -Dhttps.protocols=TLSv1.2 -Dmaven.buildNumber.doCheck=false -Dmaven.buildNumber.doUpdate=false`. Output `target/ZY.war`.
- prebuilt: `COPY --from=builder /project/target/ZY.war /var/lib/jetty/webapps/ROOT.war`.

## Entrypoint/flags
- on-demand: `CMD ["/default.sh"]`, VOLUME `/overrides`.
- prebuilt: `CMD ["java", "-jar", "/usr/local/jetty/start.jar"]`.
- ADD (not COPY): `scripts/default.sh`, `scripts/overrides.sh` to `/`; `overrides/settings-docker.xml` to `/usr/share/maven/ref/` (contents not fetched).

## Env vars
- base: `USER_HOME_DIR=/root`.
- on-demand and builder: `GIT_BRANCH=master`.

## Ports
- No EXPOSE. Chart and README use 8080.

## Volumes/paths
- on-demand: `/overrides`. prebuilt WAR at `/var/lib/jetty/webapps/ROOT.war`.

## User/UID
- No USER (root).

## Gotchas
- Base is `alpine-tomcat` 10.1.17 with JDK 11; README says only Tomcat 7 is known to work (conflict, see github-ajanata-pretend-youre-xyzzy.md).
- Build clones upstream `master` (unpinned at Dockerfile level).
- Maven download via third-party proxy URL.
