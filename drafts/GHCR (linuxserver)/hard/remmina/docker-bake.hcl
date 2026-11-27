target "docker-metadata-action" {}

variable "APP" {
  default = "remmina"
}

variable "VERSION" {
  // UNVERIFIED: no renovate datasource confirmed for the Ubuntu archive package. Choose one per apps/valkey before pinning.
  default = "1.4.43"
}

variable "LICENSE" {
  // Confirm the exact SPDX id from the COPYING file (GitHub API reports GPL-2.0).
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/FreeRDP/Remmina"
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
