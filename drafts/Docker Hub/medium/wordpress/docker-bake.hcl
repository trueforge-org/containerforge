target "docker-metadata-action" {}

variable "APP" {
  default = "wordpress"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=WordPress/WordPress versioning=loose
  // UNVERIFIED: datasource and depName not confirmed against the tag format (plan section 1).
  default = "7.1.5"
}

variable "LICENSE" {
  // UNVERIFIED: GPL-2.0-or-later from the WordPress project; confirm the SPDX id from license.txt in the release.
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/WordPress/WordPress"
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
