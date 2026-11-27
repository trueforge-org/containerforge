target "docker-metadata-action" {}

variable "APP" {
  default = "pavlovvr"
}

variable "VERSION" {
  // renovate: datasource=docker depName=ghcr.io/trueforge-org/steamcmd versioning=loose
  default = "20180105.0.0"
}

// UNVERIFIED: no proprietary-server precedent in this repo; confirm the convention before publishing.
variable "LICENSE" {
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://www.vankrupt.com/"
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
    "linux/amd64"
  ]
}
