target "docker-metadata-action" {}

variable "APP" {
  default = "traggo"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=traggo/server
  default = "0.8.3"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports GPL-3.0; "-only" vs "-or-later" not checked against the LICENSE text
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/traggo/server"
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
