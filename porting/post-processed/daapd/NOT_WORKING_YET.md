# daapd: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- `start.sh` still contains TODO placeholders and needs app-specific runtime startup logic.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: failed to solve: process "/bin/bash -o pipefail -c echo \"**** install build packages ****\" &&   apt-get update &&   apt-get install -y --no-install-recommends     libasound2-dev     autoconf     automake     libavahi-client-dev     libavahi-common-dev     bison     build-essential     libconfuse-dev     libcurl4-openssl-dev     libavcodec-dev     libavformat-dev     libavutil-dev     libflac-dev     flex     libgettextpo-dev     libgnutls28-dev     gperf     libjson-c-dev     libevent-dev     libgcrypt20-dev     libogg-dev     libplist-dev     libsodium-dev     libtool     libunistring-dev     libwebsockets-dev     libxml2-dev     libmxml-dev     default-jre-headless     libssl-dev     libprotobuf-c-dev     libsqlite3-dev     libtag1-dev &&   rm -rf /var/lib/apt/lists/* &&   mkdir -p     /tmp/source/owntone &&   echo \"**** compile owntone-server ****\" &&   curl -o   /tmp/source/owntone.tar.gz -L     \"https://github.com/owntone/owntone-server/archive/${VERSION}.tar.gz\" &&   tar xf /tmp/source/owntone.tar.gz -C     /tmp/source/owntone --strip-components=1 &&   export PATH=\"/tmp/source:$PATH\" &&   cd /tmp/source/owntone &&   autoreconf -i -v &&   ./configure     --build=$CBUILD     --enable-chromecast     --enable-lastfm     --enable-mpd     --host=$CHOST     --infodir=/usr/share/info     --localstatedir=/var     --mandir=/usr/share/man     --prefix=/usr     --sysconfdir=/etc &&   make &&   make DESTDIR=/tmp/daapd-build install &&   mv /tmp/daapd-build/etc/owntone.conf /tmp/daapd-build/etc/owntone.conf.orig &&   rm -rf /tmp/daapd-build/var" did not complete successfully: exit code: 1
