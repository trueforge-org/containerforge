target "docker-metadata-action" {}

variable "APP" {
  default = "unturned"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  // The game version is not pinned: SteamCMD downloads the current dedicated server at start.
  default = "20180105-5build1"
}

variable "LICENSE" {
  // UNVERIFIED: maintainer decision; the game is proprietary and its EULA is not confirmed.
  default = "LicenseRef-Unturned-EULA"
}

variable "SOURCE" {
  default = "https://unturned.net/"
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
