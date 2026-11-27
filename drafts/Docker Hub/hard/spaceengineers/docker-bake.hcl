target "docker-metadata-action" {}

variable "APP" {
  default = "spaceengineers"
}

variable "VERSION" {
  // renovate: datasource=deb depName=wine registryUrl=https://archive.ubuntu.com/ubuntu
  // UNVERIFIED placeholder: replace with the ubuntu 26.04 wine version from `apt-cache policy wine` before building.
  default = "UNVERIFIED"
}

variable "LICENSE" {
  // Wine is LGPL-2.1-or-later. The game server is proprietary and downloaded at runtime, not in the image.
  default = "LGPL-2.1-or-later"
}

variable "SOURCE" {
  default = "https://www.spaceengineersgame.com/"
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
  // amd64 only: the Windows server runs under Wine, which is not supported on arm64 here.
  platforms = [
    "linux/amd64"
  ]
}
