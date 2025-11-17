FROM ghcr.io/trueforge-org/ubuntu:24.4
ARG VERSION
ARG TARGETARCH
USER root

# environment variables
ENV FORCE_CONTAINER_REMOVAL=1 \
FORCE_IMAGE_REMOVAL=1


RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	git && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	bash \
	docker && \
 echo "**** fetch latest ver of docker-gc script ****" && \
 git clone https://github.com/spotify/docker-gc /tmp/docker-gc && \
 echo "**** link docker executable, copy and make docker-gc executable ****" && \
 ln -s /usr/bin/docker \
	/bin/docker && \
 cp /tmp/docker-gc/docker-gc /docker-gc && \
 chmod +x \
	/docker-gc && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# volumes
VOLUME /var/lib/docker-gc

# run command
CMD ["/docker-gc"]
