target "docker-metadata-action" {}

variable "APP" {
  default = "lyrion-music-server"
}

variable "VERSION" {
  // renovate: datasource=docker depName=lmscommunity/lyrionmusicserver versioning=loose
  default = "9.1.2"
}

variable "LICENSE" {
  // UNVERIFIED: the upstream license is not stated on lyrion.org or the GitHub README. Set it from the
  // verified source before the PR. Do not guess it.
  default = ""
}

variable "SOURCE" {
  default = "https://github.com/LMS-Community/slimserver"
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
  // amd64 only: no arm64 .deb is verified upstream.
  platforms = [
    "linux/amd64"
  ]
}
