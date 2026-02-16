FROM ghcr.io/trueforge-org/node:22.22.0 AS wwwstage

ARG KASMWEB_RELEASE="46412d23aff1f45dffa83fafb04a683282c8db58"

RUN \
  echo "**** build clientside ****" && \
  export QT_QPA_PLATFORM=offscreen && \
  export QT_QPA_FONTDIR=/usr/share/fonts && \
  mkdir /src && \
  cd /src && \
  wget https://github.com/kasmtech/noVNC/tarball/${KASMWEB_RELEASE} -O - \
    | tar  --strip-components=1 -xz && \
  npm install && \
  npm run-script build

RUN \
  echo "**** organize output ****" && \
  mkdir /build-out && \
  cd /src && \
  rm -rf node_modules/ && \
  cp -R ./* /build-out/ && \
  cd /build-out && \
  rm *.md && \
  rm AUTHORS && \
  cp index.html vnc.html && \
  mkdir Downloads

FROM ghcr.io/trueforge-org/ubuntu:24.04 AS buildstage

ARG KASMVNC_COMMIT="e04731870baebd2784983fb48197a2416c7d3519"

COPY --from=wwwstage /build-out /www

RUN \
    echo "**** install build deps ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        autoconf \
        automake \
        cmake \
        libudev-dev \
        xfonts-base \
        xfonts-75dpi \
        xfonts-100dpi \
        libdrm-dev \
        libepoxy-dev \
        libjpeg-turbo8-dev \
        libjpeg-turbo8 \
        libpciaccess-dev \
        libtool \
        libwebp-dev \
        libx11-dev \
        libxau-dev \
        libxcb1-dev \
        libxcursor-dev \
        libxdmcp-dev \
        libxext-dev \
        libxfont-dev \
        libxkbfile-dev \
        libxrandr-dev \
        libxshmfence-dev \
        libxtst-dev \
        libgl1-mesa-dev \
        libgl1-mesa-dri \
        meson \
        libnettle-dev \
        libssl-dev \
        libpixman-1-dev \
        procps \
        shadow \
        libwayland-dev \
        wayland-protocols \
        libxcb-util-dev \
        libxcb-image0-dev \
        libxcb-keysyms1-dev \
        libxcb-render-util0-dev \
        libxcb-wm-dev \
        xinit \
        xkbcomp \
        xkb-data \
        xserver-xorg-core \
        xserver-xorg-dev \
        libxtrans-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN \
  echo "**** build libjpeg-turbo ****" && \
  mkdir /jpeg-turbo && \
  JPEG_TURBO_RELEASE=$(curl -sX GET "https://api.github.com/repos/libjpeg-turbo/libjpeg-turbo/releases/latest" \
  | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  curl -o \
  /tmp/jpeg-turbo.tar.gz -L \
    "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/${JPEG_TURBO_RELEASE}.tar.gz" && \
  tar xf \
  /tmp/jpeg-turbo.tar.gz -C \
    /jpeg-turbo/ --strip-components=1 && \
  cd /jpeg-turbo && \
  MAKEFLAGS=-j`nproc` \
  CFLAGS="-fpic" \
  cmake -DCMAKE_INSTALL_PREFIX=/usr/local -G"Unix Makefiles" && \
  make && \
  make install

RUN \
  echo "**** build kasmvnc ****" && \
  git clone https://github.com/kasmtech/KasmVNC.git src && \
  cd /src && \
  git checkout -f ${KASMVNC_COMMIT} && \
  sed -i \
    -e '/find_package(FLTK/s@^@#@' \
    -e '/add_subdirectory(tests/s@^@#@' \
    CMakeLists.txt && \
  cmake \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DBUILD_VIEWER:BOOL=OFF \
    -DENABLE_GNUTLS:BOOL=OFF \
    . && \
  make -j4 && \
  echo "**** build xorg ****" && \
  XORG_VER="21.1.14" && \
  wget --no-check-certificate \
    -O /tmp/xorg-server-${XORG_VER}.tar.gz \
    "https://www.x.org/archive/individual/xserver/xorg-server-${XORG_VER}.tar.gz" && \
  tar --strip-components=1 \
    -C unix/xserver \
    -xf /tmp/xorg-server-${XORG_VER}.tar.gz && \
  cd unix/xserver && \
  patch -Np1 -i ../xserver21.patch && \
  patch -s -p0 < ../CVE-2022-2320-v1.20.patch && \
  autoreconf -i && \
  ./configure \
    --disable-config-hal \
    --disable-config-udev \
    --disable-dmx \
    --disable-dri \
    --disable-dri2 \
    --disable-kdrive \
    --disable-static \
    --disable-xephyr \
    --disable-xinerama \
    --disable-xnest \
    --disable-xorg \
    --disable-xvfb \
    --disable-xwayland \
    --disable-xwin \
    --enable-dri3 \
    --enable-glx \
    --prefix=/opt/kasmweb \
    --with-default-font-path="/usr/share/fonts/X11/misc,/usr/share/fonts/X11/cyrillic,/usr/share/fonts/X11/100dpi/:unscaled,/usr/share/fonts/X11/75dpi/:unscaled,/usr/share/fonts/X11/Type1,/usr/share/fonts/X11/100dpi,/usr/share/fonts/X11/75dpi,built-ins" \
    --without-dtrace \
    --with-sha1=libcrypto \
    --with-xkb-bin-directory=/usr/bin \
    --with-xkb-output=/var/lib/xkb \
    --with-xkb-path=/usr/share/X11/xkb && \
  find . -name "Makefile" -exec sed -i 's/-Werror=array-bounds//g' {} \; && \
  make -j4

RUN \
  echo "**** generate final output ****" && \
  cd /src && \
  mkdir -p xorg.build/bin && \
  cd xorg.build/bin/ && \
  ln -s /src/unix/xserver/hw/vnc/Xvnc Xvnc && \
  cd .. && \
  mkdir -p man/man1 && \
  touch man/man1/Xserver.1 && \
  cp /src/unix/xserver/hw/vnc/Xvnc.man man/man1/Xvnc.1 && \
  mkdir lib && \
  cd lib && \
  ln -s /usr/lib/xorg/modules/dri dri && \
  cd /src && \
  mkdir -p builder/www && \
  cp -ax /www/* builder/www/ && \
  make servertarball && \
  mkdir /build-out && \
  tar xzf \
    kasmvnc-Linux*.tar.gz \
    -C /build-out/

# nodejs builder
FROM ghcr.io/trueforge-org/node:22.22.0 AS nodebuilder
ARG KCLIENT_RELEASE

RUN \
    echo "**** install build deps ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        g++ \
        gcc \
        make \
        libpulse-dev \
        python3.11 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN \
  echo "**** grab source ****" && \
  mkdir -p /kclient && \
  if [ -z ${KCLIENT_RELEASE+x} ]; then \
    KCLIENT_RELEASE=$(curl -sX GET "https://api.github.com/repos/linuxserver/kclient/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
  /tmp/kclient.tar.gz -L \
    "https://github.com/linuxserver/kclient/archive/${KCLIENT_RELEASE}.tar.gz" && \
  tar xf \
  /tmp/kclient.tar.gz -C \
    /kclient/ --strip-components=1

RUN \
  echo "**** install node modules ****" && \
  cd /kclient && \
  npm install && \
  rm -f package-lock.json

# runtime stage
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root
ARG KASMBINS_RELEASE="1.15.0"
LABEL "com.kasmweb.image"="true"

# env
ENV DISPLAY=:1 \
    PERL5LIB=/usr/local/bin \
    OMP_WAIT_POLICY=PASSIVE \
    GOMP_SPINCOUNT=0 \
    HOME=/config \
    START_DOCKER=true \
    PULSE_RUNTIME_PATH=/defaults \
    NVIDIA_DRIVER_CAPABILITIES=all

# copy over build output
COPY --from=nodebuilder /kclient /kclient
COPY --from=buildstage /build-out/ /

RUN \
    echo "**** install deps ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        cups \
        cups-client \
        dbus-x11 \
        docker.io \
        docker-compose \
        dunst \
        ffmpeg \
        fonts-noto \
        fonts-noto-color-emoji \
        fuse-overlayfs \
        intel-media-va-driver \
        iproute2 \
        libgcc-s1 \
        libgomp1 \
        libjpeg-turbo8 \
        libnotify-bin \
        libstdc++6 \
        libwebp6 \
        libxfont2 \
        libxshmfence1 \
        mcookie \
        libgl1-mesa-dri \
        libgbm1 \
        libgl1-mesa-glx \
        mesa-vulkan-drivers \
        nginx \
        openbox \
        openssh-client \
        openssl \
        pciutils \
        libpixman-1-0 \
        pulseaudio \
        pulseaudio-utils \
        python3-xdg \
        python3 \
        x11-xkb-utils \
        vulkan-tools \
        xauth \
        xserver-xorg-video-amdgpu \
        xserver-xorg-video-ati \
        xserver-xorg-video-intel \
        xserver-xorg-video-nouveau \
        xserver-xorg-video-qxl \
        xkbcomp \
        xkeyboard-config \
        xterm \
        cups-pdf && \
    echo "**** printer config ****" && \
    sed -i \
        "s:^#Out.*:Out /home/kasm-user/PDF:" \
        /etc/cups/cups-pdf.conf && \
    sed -i \
        's/^SystemGroup .*/SystemGroup lpadmin root/' \
        /etc/cups/cups-files.conf && \
    echo "**** filesystem setup ****" && \
    ln -s /usr/local/share/kasmvnc /usr/share/kasmvnc && \
    ln -s /usr/local/etc/kasmvnc /etc/kasmvnc && \
    ln -s /usr/local/lib/kasmvnc /usr/lib/kasmvncserver && \
    echo "**** openbox tweaks ****" && \
    sed -i \
        -e 's/NLIMC/NLMC/g' \
        -e 's|</applications>|  <application class="*"><maximized>yes</maximized></application>\n</applications>|' \
        -e 's|</keyboard>|  <keybind key="C-S-d"><action name="ToggleDecorations"/></keybind>\n</keyboard>|' \
        /etc/xdg/openbox/rc.xml && \
    echo "**** user perms ****" && \
    echo "apps:apps" | chpasswd && \
    usermod -s /bin/bash apps && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/wheel && \
    adduser apps wheel && \
    echo "**** proot-apps ****" && \
    mkdir /proot-apps/ && \
    PAPPS_RELEASE=$(curl -sX GET "https://api.github.com/repos/linuxserver/proot-apps/releases/latest" \
        | awk '/tag_name/{print $4;exit}' FS='[""]') && \
    curl -L https://github.com/linuxserver/proot-apps/releases/download/${PAPPS_RELEASE}/proot-apps-$TARGETARCH.tar.gz \
        | tar -xzf - -C /proot-apps/ && \
    echo "${PAPPS_RELEASE}" > /proot-apps/pversion && \
    echo "**** kasm support ****" && \
    useradd \
        -u 1000 -U \
        -d /home/kasm-user \
        -s /bin/bash kasm-user && \
    echo "kasm-user:kasm" | chpasswd && \
    adduser kasm-user wheel && \
    mkdir -p /home/kasm-user && \
    chown 1000:1000 /home/kasm-user && \
    mkdir -p /var/run/pulse && \
    chown 1000:root /var/run/pulse && \
    mkdir -p /kasmbins && \
    curl -s https://kasm-ci.s3.amazonaws.com/kasmbins-$TARGETARCH-${KASMBINS_RELEASE}.tar.gz \
        | tar xzvf - -C /kasmbins/ && \
    chmod +x /kasmbins/* && \
    chown -R 1000:1000 /kasmbins && \
    chown 1000:1000 /usr/share/kasmvnc/www/Downloads && \
    mkdir -p /dockerstartup && \
    echo "**** dind support ****" && \
    addgroup --system dockremap && \
    adduser --system --ingroup dockremap dockremap && \
    echo 'dockremap:165536:65536' >> /etc/subuid && \
    echo 'dockremap:165536:65536' >> /etc/subgid && \
    curl -o \
    /usr/local/bin/dind -L \
        https://raw.githubusercontent.com/moby/moby/master/hack/dind && \
    chmod +x /usr/local/bin/dind && \
    usermod -aG docker apps && \
    echo 'hosts: files dns' > /etc/nsswitch.conf && \
    echo "**** theme ****" && \
    curl -s https://raw.githubusercontent.com/thelamer/lang-stash/master/theme.tar.gz \
        | tar xzvf - -C /usr/share/themes/Clearlooks/openbox-3/ && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 3000 3001
VOLUME /config

WORKDIR /config
