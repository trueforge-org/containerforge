target "docker-metadata-action" {}

variable "APP" {
  default = "chivalry-medievalwarfare"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  // The game server is installed by SteamCMD at start, so VERSION tracks the steamcmd base version.
  default = "20180105-5build1"
}

variable "LICENSE" {
  // UNVERIFIED: the game is proprietary (Steam EULA). Confirm the value before merging.
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/220070/"
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
