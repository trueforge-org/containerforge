target "docker-metadata-action" {}

variable "APP" {
  default = "ffmpeg-mkvdts2ac3"
}

variable "VERSION" {
  // NOTE: Ubuntu version is tied to the version of the base image in the Dockerfile
  // TODO: Repology lookup for ubuntu_26_04/ffmpeg is disabled for now (networking issues); bump by hand
  default = "8.0.1"
}

variable "PACKAGE_VERSION" {
  default = "7:8.0.1-3ubuntu2"
}

variable "MKVDTS2AC3_VERSION" {
  // renovate: datasource=github-tags depName=JakeWharton/mkvdts2ac3
  default = "1.6.0"
}

variable "MKVDTS2AC3_SHA256" {
  // sha256 of the 1.6.0 tag tarball, computed locally (no upstream checksum).
  default = "f9f070c00648c1ea062ac772b160c61d1b222ad2b7d30574145bf230e9288982"
}

variable "LICENSE" {
  // UNVERIFIED: depends on the ubuntu ffmpeg build. mkvdts2ac3 is Apache-2.0, mkvtoolnix GPL-2.0.
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://ffmpeg.org"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PACKAGE_VERSION = "${PACKAGE_VERSION}"
    MKVDTS2AC3_VERSION = "${MKVDTS2AC3_VERSION}"
    MKVDTS2AC3_SHA256 = "${MKVDTS2AC3_SHA256}"
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
  // UNVERIFIED on arm64: the apt packages exist for arm64, but this has not been built.
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
