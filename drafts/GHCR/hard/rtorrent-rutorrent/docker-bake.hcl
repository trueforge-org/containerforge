target "docker-metadata-action" {}

variable "APP" {
  default = "rtorrent-rutorrent"
}

variable "VERSION" {
  // renovate: UNVERIFIED datasource, see plan section 5. Candidate: datasource=git-refs depName=https://github.com/Novik/ruTorrent versioning=loose
  default = "e7c81203eff5d43f6f2757ba4b05573d22f11e35"
}

variable "LICENSE" {
  // UNVERIFIED: rTorrent is GPL-2.0-only. ruTorrent licence not checked. Confirm before the PR.
  default = "GPL-2.0-only"
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
    "linux/amd64",
    "linux/arm64"
  ]
}
