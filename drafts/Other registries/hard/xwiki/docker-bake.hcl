target "docker-metadata-action" {}

variable "APP" {
  default = "xwiki"
}

variable "VERSION" {
  // renovate: datasource=maven depName=org.xwiki.platform:xwiki-platform-distribution-war versioning=loose
  default = "18.9.0"
}

variable "LICENSE" {
  default = "LGPL-2.1-only"
}

variable "SOURCE" {
  default = "https://github.com/xwiki/xwiki-platform"
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
