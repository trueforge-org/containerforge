target "docker-metadata-action" {}

variable "APP" {
  default = "mailpile"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=mailpile/Mailpile versioning=loose
  default = "1.0.0rc6"
}

// UNVERIFIED: compute from the downloaded tarball on the first build and pin here.
variable "MAILPILE_SHA256" {
  default = "UNVERIFIED"
}

// UNVERIFIED: AGPLv3 per the upstream repo (COPYING.md); confirm -only or -or-later.
variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/mailpile/Mailpile"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    MAILPILE_SHA256 = "${MAILPILE_SHA256}"
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
