target "docker-metadata-action" {}

variable "APP" {
  default = "terraria-tshock"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Pryaxis/TShock versioning=loose
  default = "6.2.1"
}

variable "TERRARIA_VERSION" {
  default = "1.4.5.8"
}

variable "LICENSE" {
  // UNVERIFIED: GPL-3.0 per the GitHub API. Confirm -only or -or-later in the repo LICENSE file.
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/Pryaxis/TShock"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    TERRARIA_VERSION = "${TERRARIA_VERSION}"
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
