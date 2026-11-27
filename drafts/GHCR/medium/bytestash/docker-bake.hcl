target "docker-metadata-action" {}

variable "APP" {
  default = "bytestash"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=jordan-dalby/ByteStash versioning=semver
  default = "v1.6.2"
}

variable "LICENSE" {
  // GitHub SPDX for the repo is GPL-3.0; the LICENSE file itself is not yet read (UNVERIFIED)
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/jordan-dalby/ByteStash"
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
