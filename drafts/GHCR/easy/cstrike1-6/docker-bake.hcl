target "docker-metadata-action" {}

variable "APP" {
  default = "cstrike1-6"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  // The game files are downloaded at start, so this is the SteamCMD package version only.
  default = "20180105-5build1"
}

variable "LICENSE" {
  // UNVERIFIED: maintainer decision. Steam EULA not confirmed, and the wrapper declares no SPDX license.
  default = "LicenseRef-Steam-EULA"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/90"
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
