# GitHub: apache/tika-docker minimal/Dockerfile (master)
Source URL(s): https://raw.githubusercontent.com/apache/tika-docker/master/minimal/Dockerfile (fetched 2026-11-27)

## Build args / stages
- ARG UID_GID="35002:35002" (global; referenced in runtime stage, TIKA-3912)
- ARG TIKA_VERSION; ARG CHECK_SIG=true; ARG JRE='openjdk-17-jre-headless'
- Base: ubuntu:jammy
- fetch_tika stage: apt gnupg2 wget ca-certificates; import https://downloads.apache.org/tika/KEYS; download
  tika-server-standard-${TIKA_VERSION}.jar from dlcdn.apache.org, then archive.apache.org, then downloads.apache.org (fallback chain); .asc likewise; gpg --verify when CHECK_SIG=true
- runtime stage: apt ${JRE} ca-certificates; ENV TIKA_VERSION; COPY jar to /tika-server-standard-${TIKA_VERSION}.jar
- USER $UID_GID; EXPOSE 9998
- ENTRYPOINT ["/bin/sh","-c","exec java -cp \"/tika-server-standard-${TIKA_VERSION}.jar:/tika-extras/*\" org.apache.tika.server.core.TikaServerCli -h 0.0.0.0 $0 $@"]
- Extra jars expected in /tika-extras/ (classpath wildcard)
