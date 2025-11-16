FROM lsiobase/ubuntu:xenial

# set version label

# copy app files
COPY app/ /opt/dockerhub-stats/

# environment settings

# package versions

# packages as variables
	g++ \
	gcc \
	git \
	make \
	ruby-dev \
	wget"
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
	"https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUX_VER}_$TARGETARCH.deb" && \
 dpkg -i /tmp/influxdb.deb && \
 curl -o \
 /tmp/grafana.deb \
	"https://grafanarel.s3.amazonaws.com/builds/grafana_${GRAFANA_VER}_$TARGETARCH.deb" && \
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
