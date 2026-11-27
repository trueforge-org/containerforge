target "docker-metadata-action" {}

variable "APP" {
  default = "sia-daemon"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/SiaFoundation/siad currentValue=master
  // UNVERIFIED: short commit from the reviewed upstream Dockerfile (66e7fc6); resolve to the full SHA before merge. Upstream is archived (2025-07-03).
  default = "66e7fc6"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/SiaFoundation/siad"
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
