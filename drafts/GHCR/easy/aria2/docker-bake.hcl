target "docker-metadata-action" {}

variable "APP" {
  default = "aria2"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=aria2/aria2 versioning=loose extractVersion=^release-(?<version>.*)$
  default = "1.37.0"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports GPL-2.0; confirm -only versus -or-later from COPYING before merge
  default = "GPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/aria2/aria2"
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
