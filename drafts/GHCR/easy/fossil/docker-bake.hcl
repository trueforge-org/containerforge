target "docker-metadata-action" {}

variable "APP" {
  default = "fossil"
}

variable "VERSION" {
  // renovate: datasource=deb depName=fossil registryUrl=https://archive.ubuntu.com/ubuntu versioning=loose
  default = "2.26"
}

variable "PACKAGE_VERSION" {
  default = "1:2.26-2"
}

variable "LICENSE" {
  // UNVERIFIED: confirm the SPDX ID on https://fossil-scm.org before merging
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://fossil-scm.org"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION         = "${VERSION}"
    PACKAGE_VERSION = "${PACKAGE_VERSION}"
  }
  labels = {
    "org.opencontainers.image.source"   = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output   = ["type=docker"]
  tags     = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits  = ["image"]
  platforms = ["linux/amd64", "linux/arm64"]
}
