target "docker-metadata-action" {}

variable "APP" {
  default = "tvhproxy"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/jkaberg/tvhProxy versioning=loose
  default = "20180108"
}

variable "TVHPROXY_COMMIT" {
  // renovate: datasource=git-refs depName=https://github.com/jkaberg/tvhProxy versioning=loose
  default = "08096e664aca5b59059de7f609bd9e0aaba95191"
}

variable "LICENSE" {
  default = "BSD-3-Clause"
}

variable "SOURCE" {
  default = "https://github.com/jkaberg/tvhProxy"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    TVHPROXY_COMMIT = "${TVHPROXY_COMMIT}"
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
