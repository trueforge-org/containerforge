target "docker-metadata-action" {}

variable "APP" {
  default = "quake3"
}

variable "VERSION" {
  // renovate: UNVERIFIED datasource and depName (ioquake3 apt package on ubuntu 26.04; pin the version here once confirmed)
  default = "UNVERIFIED"
}

variable "LICENSE" {
  default = "GPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/ioquake/ioq3"
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
