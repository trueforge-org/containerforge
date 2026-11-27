# GitHub sismics/docs Dockerfile (master) and release lookup

Source URL(s) + date:
- https://raw.githubusercontent.com/sismics/docs/master/Dockerfile
- https://api.github.com/repos/sismics/docs/releases/latest (403, see README)
- Fetched 2026-11-27

## Dockerfile (master)
- `FROM ubuntu:26.04`, single stage, `LABEL maintainer` (upstream contact, not used)
- ENV: `DEBIAN_FRONTEND noninteractive`, `LANG C.UTF-8`, `LC_ALL C.UTF-8`, `JAVA_HOME /usr/lib/jvm/java-25-openjdk-amd64/`, `JAVA_OPTIONS -Dfile.encoding=UTF-8 -Xmx1g`, `JETTY_VERSION 12.1.6`, `JETTY_HOME /opt/jetty`
- apt install (`--no-install-recommends`): vim less procps unzip wget tzdata openjdk-25-jdk ffmpeg mediainfo, plus about 30 `tesseract-ocr-<lang>` packages (ara, ces, chi-sim, chi-tra, dan, deu, fin, fra, heb, hin, hun, ita, jpn, kor, lav, nld, nor, pol, por, rus, spa, swe, tha, tur, ukr, vie, sqi, srp); `apt-get clean`; lists removed
- `RUN dpkg-reconfigure -f noninteractive tzdata`
- Jetty: `wget` `https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/${JETTY_VERSION}/jetty-home-${JETTY_VERSION}.tar.gz` to `/tmp/jetty.tar.gz`; extract to `/opt`; `mv /opt/jetty* /opt/jetty`; `useradd jetty -U -s /bin/false`; `chown -R jetty:jetty /opt/jetty`; `mkdir /opt/jetty/webapps`; `chmod +x /opt/jetty/bin/jetty.sh`
- `EXPOSE 8080`
- App: `mkdir /app`; `cd /app && java -jar /opt/jetty/start.jar --add-modules=server,http,ee11-webapp,ee11-deploy`
- `ADD docs.xml /app/webapps/docs.xml`; `ADD docs-web/target/docs-web-*.war /app/webapps/docs.war`
- `WORKDIR /app`; `CMD ["java", "-jar", "/opt/jetty/start.jar"]`
- Runs as root (no USER). No HEALTHCHECK, no VOLUME.

## Gotchas
- Master Dockerfile; the draft's pinned commit `5b39c46` was not fetched.
- The WAR `docs-web-*.war` is built by Maven in upstream's build; release WAR asset is separate (see github-teedy-dockerfile.md, release lookup failed).
- Release API rate-limited, so release asset names come from the plan only (unverified here).
