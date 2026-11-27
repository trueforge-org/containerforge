target "docker-metadata-action" {}

// renovate: datasource=github-tags depName=gpodder/gpodder versioning=semver
variable "VERSION" {
  default = "3.11.5"
}

variable "APP" {
  default = "gpodder"
}

// UNVERIFIED: SPDX suffix (-only or -or-later) must be checked against upstream license text
variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/gpodder/gpodder"
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
