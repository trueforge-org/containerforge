target "docker-metadata-action" {}

variable "APP" {
  default = "steamcmd"
}

variable "VERSION" {
  default = "1.0.0"
}

variable "STEAMCMD_SHA256" {
  default = "cebf0046bfd08cf45da6bc094ae47aa39ebf4155e5ede41373b579b8f1071e7c"
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
    STEAMCMD_SHA256 = "${STEAMCMD_SHA256}"
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
