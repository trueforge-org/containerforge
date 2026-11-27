target "docker-metadata-action" {}

variable "APP" {
  default = "quassel-core"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=quassel/quassel versioning=loose
  default = "0.14.0"
}

variable "PACKAGE_VERSION" {
  // NOTE: must match the Ubuntu quassel-core package for the base image (epoch included). Maintain with the base.
  default = "1:0.14.0-4ubuntu2"
}

variable "LICENSE" {
  // UNVERIFIED: GPL-2.0-or-later per upstream COPYING; GitHub reports NOASSERTION. Check COPYING.
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/quassel/quassel"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PACKAGE_VERSION = "${PACKAGE_VERSION}"
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
