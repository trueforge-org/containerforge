FROM scratch
ADD rootfs.tar.xz /

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# build variables
ARG GOPATH=/tmp/golang
ARG MANIFEST_DIR=$GOPATH/src/github.com/estesp/manifest-tool
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
