target "docker-metadata-action" {}

variable "APP" {
  default = "owi2plex"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=owi2plex versioning=pep440
  default = "0.1a14"
}

variable "LICENSE" {
  default = "MPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/cvarelaruiz/owi2plex"
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
