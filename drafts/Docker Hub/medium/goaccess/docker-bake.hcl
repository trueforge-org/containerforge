target "docker-metadata-action" {}

variable "APP" {
  default = "goaccess"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=allinurl/goaccess versioning=loose
  // UNVERIFIED: v1.12 release not confirmed (API returned 403); the tag v1.12 exists and COPYING is MIT
  default = "v1.12"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/allinurl/goaccess"
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
