target "docker-metadata-action" {}

variable "APP" {
  default = "yacreaderlibraryserver"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=YACReader/yacreader versioning=loose
  default = "10.4.0"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub SPDX reports GPL-3.0. Confirm against the LICENSE file at the tag.
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/YACReader/yacreader"
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
