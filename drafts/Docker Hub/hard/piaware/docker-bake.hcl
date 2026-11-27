target "docker-metadata-action" {}

variable "APP" {
  default = "piaware"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=flightaware/piaware versioning=loose extractVersion=^v(?<version>.+)$
  default = "11.1"
}

// UNVERIFIED: the image also ships dump1090-fa (GPL-2.0-or-later). Review the combined license before merge.
variable "LICENSE" {
  default = "BSD-2-Clause"
}

variable "SOURCE" {
  default = "https://github.com/flightaware/piaware/"
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
