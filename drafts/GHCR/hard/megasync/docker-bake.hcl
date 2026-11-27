target "docker-metadata-action" {}

variable "APP" {
  default = "megasync"
}

variable "VERSION" {
  // UNVERIFIED: the version comes from a directory listing, so no standard renovate datasource fits.
  // renovate: datasource=custom.megasync depName=megasync versioning=loose
  default = "6.7.1-1.1"
}

variable "LICENSE" {
  // UNVERIFIED: closed-source MEGA client. The SPDX id is not confirmed.
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/meganz/MEGAsync"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
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

// UNVERIFIED: the arm64 runtime and the amd64 Debian 12 deb on 26.04 are not tested. Do not claim both arches until they run.
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
