target "docker-metadata-action" {}

variable "APP" {
  default = "jts3servermod"
}

// UNVERIFIED: no application release exists upstream. This is the wrapper image tag.
// renovate: datasource=docker depName=ghcr.io/galexrt/jts3servermod versioning=loose
variable "VERSION" {
  default = "v20240301-172535-248"
}

// UNVERIFIED: the wrapper license. The license of the vendor zip is not confirmed.
variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/galexrt/container-jts3servermod"
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
