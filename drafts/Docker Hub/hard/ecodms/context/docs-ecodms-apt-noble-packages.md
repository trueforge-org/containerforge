# ecoDMS apt repository index (noble)

Source URL(s) + fetch date:
- http://www.ecodms.de/ecodms_260164/noble/ (directory): HTTP 403 Forbidden (failure).
- Alternative tried: http://www.ecodms.de/ecodms_260164/noble/Packages (plain text Debian Packages index): fetched 2026-11-26.

## Packages (6 stanzas)
- ecodmsserver 26.01-4, amd64, Installed-Size 1447756, Filename `./ecodmsserver-26.01-4_amd64.deb`.
  - Depends: libqt5core5a, libqt5gui5, libqt5sql5, libqt5xml5, libqt5widgets5, libqt5network5, libqt5sql5-psql, sudo, postgresql, postgresql-16-pgvector, samba, samba-common-bin, libjpeg8, zlib1g, libssl3, libapr1, liblcms2-2, libtiff6, libpng16-16, libjbig0, libgpg-error0, libgcrypt20, libopenjp2-7, haveged, libidn12, libwebpmux3, postgresql-ecodms-vectorizeimage.
  - No Java, OpenJDK or Tomcat in Depends. PostgreSQL is an apt dependency, not bundled.
- ecodmsclient 26.01-3, amd64. Depends long Qt5/GTK/libpq5 list.
- ecodmsmailzplugin 26.01-3, amd64. Depends: ecodmsclient.
- ecodmspackages 26.01-4, amd64. No Depends listed.
- ecodmsprinter 26.01-3, amd64. Depends: ecodmsclient, cups-pdf, poppler-utils.
- postgresql-ecodms-vectorizeimage 1.0-1, amd64.

## Gotchas
- All packages `amd64`. No arm64 index in this repo listing.
- samba is a dependency, so the server brings Samba (the Hub notes scaninput can be shared via Samba).
- The noble index is for Ubuntu 24.04. Ubuntu 26.04 is not covered.
