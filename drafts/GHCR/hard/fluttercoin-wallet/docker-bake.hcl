target "docker-metadata-action" {}

variable "APP" {
  default = "fluttercoin-wallet"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ofeefee/fluttercoin versioning=loose
  default = "v0.7.5.22-flt"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/ofeefee/fluttercoin"
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
  // amd64 only: the upstream release has no arm64 build
  platforms = [
    "linux/amd64"
  ]
}
