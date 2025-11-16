FROM lsiobase/ubuntu:xenial

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="phendryx"

# copy app files
COPY app/ /opt/dockerhub-stats/

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

# package versions
ARG GRAFANA_VER="4.1.2-1486989747"
ARG INFLUX_VER="1.2.0"

# packages as variables
ARG BUILD_PACKAGES="\
	g++ \
	gcc \
	git \
	make \
	ruby-dev \
	wget"
ARG RUNTIME_PACKAGES="\
	cron \
	libfontconfig1 \
	libfreetype6 \
	libpng12-0 \
	netcat \
	ruby \
	wget"
RUN \
 echo "**** install build packages ****" && \
 apt-get update && \
 apt-get install -y \
	--no-install-recommends \
	$BUILD_PACKAGES && \
 echo "**** install ruby app gems ****" && \
 cd /opt/dockerhub-stats/ && \
 echo 'gem: --no-document' > \
	/etc/gemrc && \
 gem install bundler && \
 bundle install && \
 echo "**** uninstall build packages ****" && \
 apt-get purge -y --auto-remove \
	$BUILD_PACKAGES && \
 echo "****install runtime packages ****" && \
 apt-get install -y \
	--no-install-recommends \
	$RUNTIME_PACKAGES && \
 echo "**** install influxdb and grafana ****" && \
 curl -o \
 /tmp/influxdb.deb \
	"https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUX_VER}_amd64.deb" && \
 dpkg -i /tmp/influxdb.deb && \
 curl -o \
 /tmp/grafana.deb \
	"https://grafanarel.s3.amazonaws.com/builds/grafana_${GRAFANA_VER}_amd64.deb" && \
 dpkg -i /tmp/grafana.deb && \
 apt-get -f install && \
 echo "**** cleanup ****" && \
 rm -rf \
	/root \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/* && \
 mkdir -p \
	/root

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 3000 8083 8086 4567
VOLUME /config
