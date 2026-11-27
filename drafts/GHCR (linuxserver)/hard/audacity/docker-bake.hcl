target "docker-metadata-action" {}

variable "APP" {
  default = "audacity"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=audacity/audacity versioning=loose
  default = "4.0.2"
}

variable "LICENSE" {
  // UNVERIFIED placeholder: GitHub reports NOASSERTION. Set the SPDX id after reading LICENSE.txt in the source tree.
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/audacity/audacity"
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
