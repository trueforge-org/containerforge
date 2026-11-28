target "docker-metadata-action" {}

variable "APP" {
  default = "lastoasis"
}

variable "VERSION" {
  // renovate: datasource=docker depName=ghcr.io/trueforge-org/steamcmd versioning=loose
  default = "20180105.0.0"
}

variable "LICENSE" {
  // Proprietary game under the Steam Subscriber Agreement; not an SPDX identifier.
  default = "LicenseRef-Steam-EULA"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/903950/Last_Oasis/"
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
