target "docker-metadata-action" {}

variable "APP" {
  default = "insurgencysandstorm"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  // The server is installed by SteamCMD at start, so VERSION tracks the steamcmd base version.
  default = "20180105-5build1"
}

variable "LICENSE" {
  // UNVERIFIED: proprietary Steam EULA. Confirm the value before merging.
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  // The draft's store page (581320) is the client. The server app id is UNVERIFIED (see start.sh).
  default = "https://store.steampowered.com/app/581320/"
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
