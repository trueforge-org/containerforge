target "docker-metadata-action" {}

variable "APP" {
  default = "colonysurvival"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

// UNVERIFIED: the license of the packaging and of the Steam-licensed game is not decided yet.
variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/748090/"
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

// arm64 is not supported: the SteamCMD bootstrap is 32-bit x86.
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64"
  ]
}
