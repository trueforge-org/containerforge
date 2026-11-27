target "docker-metadata-action" {}

variable "APP" {
  default = "virt-manager"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=virt-manager/virt-manager versioning=semver extractVersion=^v(?<version>.+)$
  default = "5.1.0"
}

variable "PACKAGE_VERSION" {
  // NOTE: Ubuntu 26.04 package version, tied to the base image. Bump by hand together with VERSION.
  default = "1:5.1.0-1ubuntu0.1"
}

variable "LICENSE" {
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/virt-manager/virt-manager"
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
