target "docker-metadata-action" {}

variable "APP" {
  default = "rickroll"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/modem7/docker-rickroll currentValue=master
  default = "db8d928c7a6af1b7cd4b4b12653ef5f1ec161fee"
}

variable "LICENSE" {
  // The repo is MIT. The video content licence is not stated upstream, see the PR notes.
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/modem7/docker-rickroll"
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
