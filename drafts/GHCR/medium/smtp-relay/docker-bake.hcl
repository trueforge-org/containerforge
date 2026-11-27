target "docker-metadata-action" {}

variable "APP" {
  default = "smtp-relay"
}

variable "VERSION" {
  // renovate: datasource=deb depName=exim4-daemon-light versioning=deb
  // UNVERIFIED: the deb datasource and its registry URL for the Ubuntu archive. Fall back to a manual bump if renovate cannot read it.
  default = "4.99.1"
}

variable "LICENSE" {
  // UNVERIFIED: confirm against the Exim copyright file before commit.
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/Exim/exim"
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
