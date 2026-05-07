target "docker-metadata-action" {}

variable "APP" {
  default = "valkey"
}

variable "VERSION" {
  // NOTE: Ubuntu version is tied to the version of the base image in the Dockerfile
  // renovate: datasource=repology depName=ubuntu_26_04/valkey versioning=loose
  default = "9.0.3"
}

variable "PACKAGE_VERSION" {
  default = "9.0.3-0ubuntu2"
}

variable "LICENSE" {
  default = "BSD-3-Clause"
}

variable "SOURCE" {
  default = "https://valkey.io"
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
