target "docker-metadata-action" {}

variable "APP" {
  default = "pixark"
}

variable "VERSION" {
  // UNVERIFIED: no pinnable Pixark server version or build source found yet
  // renovate: datasource=UNVERIFIED depName=UNVERIFIED
  default = "UNVERIFIED"
}

variable "STEAMCMD_VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

variable "LICENSE" {
  // UNVERIFIED: license of the Pixark server files is not confirmed
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/824360"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    STEAMCMD_VERSION = "${STEAMCMD_VERSION}"
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
  // amd64 only: the server is a Windows build run under Wine
  platforms = [
    "linux/amd64"
  ]
}
