target "docker-metadata-action" {}

variable "APP" {
  default = "nginx"
}

variable "VERSION" {
  // NOTE: Ubuntu version is tied to the version of the base image in the Dockerfile
  // renovate: datasource=repology depName=ubuntu_26_04/nginx versioning=loose
  default = "1.28.3-2ubuntu1"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://hub.docker.com/_/nginx"
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
