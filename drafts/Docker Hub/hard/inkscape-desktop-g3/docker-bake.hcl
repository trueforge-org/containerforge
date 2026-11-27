target "docker-metadata-action" {}

variable "APP" {
  default = "inkscape-desktop-g3"
}

// NOTE: Ubuntu version is tied to the version of the base image in the Dockerfile
// TODO: temporary disabled due to repology networking issues
// repologydepName=ubuntu_26_04/inkscape versioning=loose
variable "VERSION" {
  default = "1.4.3"
}

variable "PACKAGE_VERSION" {
  default = "1.4.3-0ubuntu2"
}

variable "LICENSE" {
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://inkscape.org/"
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
