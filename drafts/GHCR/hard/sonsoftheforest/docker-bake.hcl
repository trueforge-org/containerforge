target "docker-metadata-action" {}

variable "APP" {
  default = "sonsoftheforest"
}

variable "VERSION" {
  // UNVERIFIED: game build version not known; needs a datasource chosen for SteamCMD-served games
  // renovate: datasource=custom.steam depName=sonsoftheforest versioning=loose
  default = "unverified"
}

variable "LICENSE" {
  // UNVERIFIED: no license found for the server or for Wine-hosted binaries
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/1326470/"
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
  // amd64 only: the server runs under Wine on an amd64 base
  platforms = [
    "linux/amd64"
  ]
}
