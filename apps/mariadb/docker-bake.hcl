target "docker-metadata-action" {}

variable "APP" {
  default = "mariadb"
}

variable "VERSION" {
  // NOTE: Ubuntu version is tied to the version of the base image in the Dockerfile
  // TODO: temporary disabled due to repology networking issues (it being in russia)
  // repologydepName=ubuntu_26_04/mariadb versioning=loose
  default = "11.8.6"
}

variable "PACKAGE_VERSION" {
  default = "1:11.8.6-5ubuntu0.1"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://mariadb.org/"
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
