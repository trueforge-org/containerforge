target "docker-metadata-action" {}

variable "APP" {
  default = "sinusbot"
}

variable "VERSION" {
  // UNVERIFIED: no renovate datasource fits a closed vendor tarball. Pick one before the bake is final.
  // renovate: datasource=custom.sinusbot depName=sinusbot versioning=loose
  default = "1.1f"
}

variable "LICENSE" {
  // UNVERIFIED: closed-source vendor licence. Linux use needs a TeamSpeak licence or a hosting provider.
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/gamer92000/sinusbot-docker"
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

// amd64 only: the vendor binary has no arm64 build. The Dockerfile refuses other arches.
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64"
  ]
}
