target "docker-metadata-action" {}

variable "APP" {
  default = "misskey"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=misskey-dev/misskey versioning=loose
  default = "2026.11.0"
}

variable "SRC_SHA256" {
  // UNVERIFIED: fill in the sha256 of the 2026.11.0 tag tarball before building. Bump by hand with VERSION.
  default = ""
}

variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/misskey-dev/misskey"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SRC_SHA256 = "${SRC_SHA256}"
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
