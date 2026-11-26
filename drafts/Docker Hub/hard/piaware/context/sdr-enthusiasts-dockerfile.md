# sdr-enthusiasts/docker-piaware Dockerfile (pinned commit bedde2040fd15c25cf001e1575915593124c34a7)

Source URL: https://raw.githubusercontent.com/sdr-enthusiasts/docker-piaware/bedde2040fd15c25cf001e1575915593124c34a7/Dockerfile (fetched; blob URL in urls.txt)
Also fetched: https://raw.githubusercontent.com/sdr-enthusiasts/docker-piaware/main/Dockerfile (same structure; main branch)

## Base / ENV
- FROM ghcr.io/sdr-enthusiasts/docker-baseimage:dump978-full (not digest-pinned); s6-overlay from base
- ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2, VERBOSE_LOGGING="false"; no ARGs; SHELL bash -o pipefail -c

## Packages
- Runtime apt: libusb-1.0-0, libatomic1, libncurses6, tcl, tcl-tls, tclx, lighttpd, lighttpd-mod-deflate, python3-minimal, python3-pkg-resources, itcl3, tcllib, net-tools, procps, socat, libboost-system1.74.0, libboost-program-options1.74.0, libboost-regex1.74.0
- Temp build apt (autoremoved): automake, build-essential, cmake, git, pkg-config, gnupg2, file, libusb-1.0-0-dev, libncurses-dev, tcl-dev, python3-distutils, python3-dev, python3-setuptools, libboost1.74-dev (+ system/program-options/regex dev)
- --no-install-recommends

## Source builds (all GitHub, UNPINNED: latest v* tag via git ls-remote, shallow clone)
- tcllauncher (flightaware): autoconf; ./configure --prefix=/opt/tcl; make install
- piaware (flightaware): make install; copies package/ca/*.pem to /etc/ssl/; creates /etc/piaware.conf and /run/piaware; sed-patches /usr/lib/piaware/login.tcl to report package version and image type piaware_package
- piaware-web (flightaware): full clone, default branch; web/ -> /var/www/html/
- dump1090 (flightaware): RTLSDR=yes; view1090, dump1090 -> /usr/local/bin/; faup1090 -> /usr/lib/piaware/helpers/; public_html -> /usr/share/skyaware/html
- mlat-client (mutability): setup.py install; fa-mlat-client symlinked into /usr/lib/piaware/helpers/
- beast-splitter (flightaware): binary -> /usr/local/bin/
- symlink /usr/share/dump978-fa -> /usr/share/skyaware978
- Versions appended to /VERSIONS; /IMAGE_VERSION from piaware line

## Image config
- COPY rootfs/ -> /
- EXPOSE 80/tcp, 30003, 30005, 30105, 30978, 30979 (tcp)
- USER/WORKDIR/VOLUME/ENTRYPOINT/CMD: none (inherited from base)
- HEALTHCHECK: /scripts/healthcheck.sh, start-period 7200s, interval 600s
- Cleanup: temp pkgs, apt caches, __pycache__, /src, /tmp/*, /var/log/*, /var/cache/*

## Gotchas
- main-branch version also contains a conditional tcltls build on non-bookworm and Boost 1.87 patch (/patches bind-mount at build time). Pinned commit is the Boost 1.74 variant.
- rootfs/ (s6 service defs) not shown.
