target "docker-metadata-action" {}

variable "APP" {
  default = "survivethenights"
}

variable "VERSION" {
  // UNVERIFIED: tag of the ContainerForge steamcmd base image. Renovate annotation to be set once confirmed.
  // renovate: datasource=docker depName=ghcr.io/trueforge-org/steamcmd versioning=loose
  default = "UNVERIFIED"
}

// UNVERIFIED: the license of the packaging and of the Steam-licensed game is not decided yet.
variable "LICENSE" {
  default = "UNVERIFIED"
}

// UNVERIFIED: store page from the draft. The dedicated server app ID is not confirmed.
variable "SOURCE" {
  default = "https://store.steampowered.com/app/541300/"
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
