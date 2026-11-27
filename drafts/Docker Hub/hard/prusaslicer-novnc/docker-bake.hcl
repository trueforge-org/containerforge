target "docker-metadata-action" {}

variable "APP" {
  default = "prusaslicer-novnc"
}

variable "VERSION" {
  // UNVERIFIED: set to the Ubuntu 26.04 prusa-slicer upstream version once checked.
  // renovate: datasource=repology depName=ubuntu_26_04/prusa-slicer versioning=loose
  default = "2.9.4"
}

variable "PACKAGE_VERSION" {
  // UNVERIFIED: exact apt version, must start with VERSION. Empty fails the build on purpose.
  default = ""
}

variable "LICENSE" {
  // UNVERIFIED: read the LICENSE file before setting AGPL-3.0-only or -or-later.
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/prusa3d/PrusaSlicer/"
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
