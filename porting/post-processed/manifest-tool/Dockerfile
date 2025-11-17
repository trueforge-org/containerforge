FROM ghcr.io/trueforge-org/ubuntu:24.4
ARG VERSION
ARG TARGETARCH
USER root

# set version label

# build variables
# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	g++ \
	gcc \
	git \
	go \
	make && \
# install runtime packages
 apk add --no-cache \
	docker && \
# compile manifest-tool
 git clone https://github.com/estesp/manifest-tool ${MANIFEST_DIR} && \
 git -C $MANIFEST_DIR checkout $(git -C $MANIFEST_DIR describe --tags --candidates=1 --abbrev=0) && \
 cd ${MANIFEST_DIR} && \
 export PATH=$GOPATH/bin:$PATH && \
 make binary && \
 install -Dm755 \
 	${MANIFEST_DIR}/manifest-tool \
	/usr/bin/manifest-tool && \
# cleanup
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*
