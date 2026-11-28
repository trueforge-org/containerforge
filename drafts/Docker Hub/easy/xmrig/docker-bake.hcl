target "docker-metadata-action" {}

variable "APP" {
  default = "xmrig"
}

variable "VERSION" {
  // NOTE: Ubuntu version is tied to the version of the base image in the Dockerfile
  // TODO: apt package version cannot be tracked by a stable datasource (upstream is at 6.27.0)
  // repologydepName=ubuntu_26_04/xmrig versioning=loose
  default = "6.25.0"
}

variable "PACKAGE_VERSION" {
  default = "6.25.0+dfsg-1"
}

variable "LICENSE" {
  default = "GPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/xmrig/xmrig"
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
