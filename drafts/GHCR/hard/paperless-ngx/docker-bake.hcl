target "docker-metadata-action" {}

variable "APP" {
  default = "paperless-ngx"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=paperless-ngx/paperless-ngx versioning=semver
  default = "3.5.1"
}

variable "LICENSE" {
  // UNVERIFIED: confirm GPL-3.0-only vs GPL-3.0-or-later from the LICENSE file header.
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/paperless-ngx/paperless-ngx"
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
