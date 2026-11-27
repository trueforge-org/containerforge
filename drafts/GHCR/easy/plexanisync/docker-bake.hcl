target "docker-metadata-action" {}

variable "APP" {
  default = "plexanisync"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=RickDB/PlexAniSync versioning=semver
  default = "1.4.4"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports GPL-3.0. Confirm the exact SPDX id from the LICENSE text.
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/RickDB/PlexAniSync"
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
