target "docker-metadata-action" {}

variable "APP" {
  default = "peppermint"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/Peppermint-Lab/peppermint currentValue=main
  // UNVERIFIED: commit from the pinned upstream Dockerfile in context; the 0.5.5 release has no assets. Confirm the commit before merge.
  default = "ba6e2179f9409db76abeb9a3007a262160e24628"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports NOASSERTION; set the SPDX id from the LICENSE file
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/Peppermint-Lab/peppermint"
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
