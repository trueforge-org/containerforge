target "docker-metadata-action" {}

variable "APP" {
  default = "citadel-forgedwithfire"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

// UNVERIFIED: the game is proprietary Steam software; the project's license for this image is to be decided.
variable "LICENSE" {
  default = "LicenseRef-Proprietary"
}

// UNVERIFIED: store search link used because no Steam app page was confirmed.
variable "SOURCE" {
  default = "https://store.steampowered.com/search/?term=Citadel+Forged+with+Fire"
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
