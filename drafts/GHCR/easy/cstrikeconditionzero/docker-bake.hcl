target "docker-metadata-action" {}

variable "APP" {
  default = "cstrikeconditionzero"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

// UNVERIFIED: the game is under the Steam EULA and the upstream wrapper declares no SPDX license.
variable "LICENSE" {
  default = "UNVERIFIED: Steam EULA; wrapper declares no SPDX"
}

// UNVERIFIED: store search page from the draft. Consider the Steam app page for app 90 instead.
variable "SOURCE" {
  default = "https://store.steampowered.com/search/?term=Counter-Strike+Condition+Zero"
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
