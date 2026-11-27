target "docker-metadata-action" {}

variable "APP" {
  default = "photoshow"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/thibaud-rohmer/PhotoShow currentValue=master
  default = "3c3819f6555c1c7819ee31f6c090da44d0ce2428"
}

variable "LICENSE" {
  // PLACEHOLDER: upstream declares no license (no LICENSE file, GitHub license null).
  // Confirm with upstream or the user before merging, and check the SPDX convention used by sibling apps.
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/thibaud-rohmer/PhotoShow"
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
