target "docker-metadata-action" {}

variable "APP" {
  default = "zoneminder"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ZoneMinder/zoneminder versioning=semver
  default = "1.38.6"
}

variable "LICENSE" {
  // UNVERIFIED: confirm the SPDX id against the upstream LICENSE before commit
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/ZoneMinder/zoneminder"
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
