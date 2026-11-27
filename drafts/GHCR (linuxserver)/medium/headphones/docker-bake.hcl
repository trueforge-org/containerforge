target "docker-metadata-action" {}

variable "APP" {
  default = "headphones"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=rembo10/headphones versioning=semver
  default = "v0.6.4"
}

variable "LICENSE" {
  // UNVERIFIED: confirm the copyright headers before committing (GPL-3.0-only vs GPL-3.0-or-later)
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/rembo10/headphones"
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
