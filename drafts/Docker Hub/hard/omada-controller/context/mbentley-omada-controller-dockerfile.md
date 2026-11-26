# mbentley/docker-omada-controller Dockerfile

Source URL(s): https://github.com/mbentley/docker-omada-controller/blob/master/Dockerfile (raw fetched) · fetched 2026-11-26

- `ARG BASE=mbentley/ubuntu:24.04`; `FROM ${BASE}`.
- ARG `ARCH=amd64` (amd64, arm64; armv7l deprecated); `INSTALL_VER="6.3.0.112"`; `NO_MONGODB=false`; `MONGODB_VER` (unused cache-bust arg).
- LABEL: source = repo, version = ${INSTALL_VER}.
- COPY healthcheck.sh, install.sh -> /.
- RUN `/install.sh && rm /install.sh` (apt packages, download URLs, user creation are inside install.sh; not fetched).
- COPY entrypoint-unified.sh -> /entrypoint.sh.
- WORKDIR /opt/tplink/EAPController/lib.
- EXPOSE 8044, 8088, 8043, 8843, 19810/udp, 27001/udp, 29810/udp, 29811-29817.
- HEALTHCHECK `--start-period=5m CMD /healthcheck.sh`.
- VOLUME /opt/tplink/EAPController/data and /opt/tplink/EAPController/logs.
- No USER (install.sh behaviour not shown). ENTRYPOINT ["/entrypoint.sh"].
- CMD: `java -server -Xms128m -Xmx1024m -XX:MaxHeapFreeRatio=60 -XX:MinHeapFreeRatio=30 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/opt/tplink/EAPController/logs/java_heapdump.hprof -Djava.awt.headless=true -cp /opt/tplink/EAPController/lib/*:/opt/tplink/EAPController/properties com.tplink.smb.omada.starter.OmadaLinuxMain`.
