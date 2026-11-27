target "docker-metadata-action" {}

variable "APP" {
  default = "xonotic"
}

variable "VERSION" {
  // renovate: datasource=gitlab-tags depName=xonotic/xonotic versioning=loose
  default = "0.8.6"
}

variable "LICENSE" {
  // UNVERIFIED: replace with the license read from the upstream COPYING file before the first build
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://gitlab.com/xonotic/xonotic"
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
  // UNVERIFIED: arm64 needs a source compile that is not yet validated; amd64 only until then
  platforms = [
    "linux/amd64"
  ]
}
