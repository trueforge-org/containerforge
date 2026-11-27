target "docker-metadata-action" {}

variable "APP" {
  default = "debian-apt-mirror"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=apt-mirror/apt-mirror versioning=semver
  default = "0.5.4"
}

variable "LICENSE" {
  default = "GPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/apt-mirror/apt-mirror"
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
