# tar1090 web UI on the ContainerForge nginx base, with readsb built from source.
# Upstream: https://github.com/wiedehopf/tar1090 (no releases, pinned by commit in VERSION). Decoder: https://github.com/wiedehopf/readsb
# UNVERIFIED: readsb build flags, tar1090.sh arguments, and the aircraft.csv.gz download URL. Check the repos before the first build.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS builder

ARG VERSION
ARG READSB_REF

USER root
ENV HOME=/tmp
WORKDIR /src

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential git pkg-config librtlsdr-dev libusb-1.0-0-dev libncurses-dev zlib1g-dev libzstd-dev ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

# tar1090 web app at the pinned commit (VERSION). Its version file reads 3.14.1827.
ADD https://github.com/wiedehopf/tar1090.git#${VERSION} /src

# readsb is pinned by READSB_REF; an empty value builds the default branch.
RUN git clone https://github.com/wiedehopf/readsb.git /src/readsb && \
    if [ -n "${READSB_REF}" ]; then git -C /src/readsb checkout "${READSB_REF}"; fi && \
    make -C /src/readsb RTLSDR=yes -j"$(nproc)"

RUN curl -fsSL -o /tmp/aircraft.csv.gz "https://raw.githubusercontent.com/wiedehopf/tar1090-db/csv/aircraft.csv.gz" && \
    gzip -t /tmp/aircraft.csv.gz && \
    install -m 0644 /tmp/aircraft.csv.gz /src/html/aircraft.csv.gz && \
    rm /tmp/aircraft.csv.gz

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f

USER root

# UNVERIFIED: which of these the nginx base already provides; apt skips installed packages.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        librtlsdr0 libusb-1.0-0 libncurses6 libzstd1 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/readsb/readsb /usr/local/bin/readsb
COPY --from=builder /src/html /app/tar1090/html
COPY --from=builder /src/tar1090.sh /app/tar1090/tar1090.sh
COPY --from=builder /src/LICENSE /usr/share/licenses/tar1090/LICENSE
COPY --from=builder /src/readsb/LICENSE /usr/share/licenses/tar1090/readsb-LICENSE

ENV HOME=/tmp

EXPOSE 8080

VOLUME /config

USER apps
COPY --chmod=0755 . /
