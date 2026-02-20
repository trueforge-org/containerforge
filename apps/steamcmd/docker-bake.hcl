target "docker-metadata-action" {}

variable "APP" {
  default = "steamcmd"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "0~20180105-5"
}

variable "IMAGE_VERSION" {
  default = "1.0.0"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://developer.valvesoftware.com/wiki/SteamCMD"
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
  tags = ["${APP}:${IMAGE_VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64"
  ]
}
