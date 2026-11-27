target "docker-metadata-action" {}

variable "APP" {
  default = "rflood"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=jesec/flood versioning=semver
  default = "4.16.4"
}

variable "RTORRENT_VERSION" {
  // renovate: datasource=github-releases depName=rakshasa/rtorrent versioning=semver
  default = "0.16.29"
}

variable "LICENSE" {
  // UNVERIFIED: rtorrent is GPL-2.0 per the GitHub API. The combined image license is not confirmed.
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/rakshasa/rtorrent"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    RTORRENT_VERSION = "${RTORRENT_VERSION}"
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
    "linux/amd64"  // arm64 not supported until a flood arm64 asset is confirmed
  ]
}
