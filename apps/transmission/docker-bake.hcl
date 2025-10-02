target "docker-metadata-action" {}

variable "APP" {
  default = "transmission"
}

variable "VERSION" {
  // NOTE: Alpine version is tied to the version of the base image in the Dockerfile
  // renovate: datasource=repology depName=alpine_3_22/transmission-daemon versioning=loose
  default = "4.0.6-r4"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/transmission/transmission"
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
