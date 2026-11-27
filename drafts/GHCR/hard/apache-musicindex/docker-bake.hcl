target "docker-metadata-action" {}

variable "APP" {
  default = "apache-musicindex"
}

// UNVERIFIED: the Ubuntu package is the source of this version (1.4.1-6). The datasource is a proposal only.
// The chart's image tag v1.4.1-2 is a different build number and is not used here.
variable "VERSION" {
  // renovate: datasource=deb depName=libapache2-mod-musicindex
  default = "1.4.1-6"
}

// UNVERIFIED: upstream page says LGPLv2.1; confirm the exact SPDX id (only or or-later) from the copyright file.
variable "LICENSE" {
  default = "LGPL-2.1"
}

variable "SOURCE" {
  default = "http://hacks.slashdirt.org/sw/musicindex/"
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

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
