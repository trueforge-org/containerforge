target "docker-metadata-action" {}

variable "APP" {
  default = "tracks"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=tracksapp/tracks versioning=loose
  // UNVERIFIED: tag format not checked; the chart image is unpinned (latest)
  default = "2.7.1"
}

variable "LICENSE" {
  // UNVERIFIED: SPDX form of GPL-2.0 to confirm against the repo LICENSE/COPYING file
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/tracksapp/tracks"
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
