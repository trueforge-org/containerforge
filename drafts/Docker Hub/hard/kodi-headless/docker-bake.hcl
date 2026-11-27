target "docker-metadata-action" {}

variable "APP" {
  default = "kodi-headless"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=xbmc/xbmc versioning=loose extractVersion=^(?<version>[0-9.]+)-Omega$
  default = "21.3"
}

variable "PACKAGE_VERSION" {
  // UNVERIFIED: apt version of kodi-bin/kodi-data on ubuntu 26.04; read with apt-cache policy kodi-bin
  default = "2:21.3+dfsg-1ubuntu1"
}

variable "LICENSE" {
  // UNVERIFIED: plan says GPL-2.0-or-later; xbmc README says GPLv2; confirm against LICENSE.md
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/xbmc/xbmc"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PACKAGE_VERSION = "${PACKAGE_VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
