target "docker-metadata-action" {}

variable "APP" {
  default = "authentik"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=goauthentik/authentik versioning=semver
  // UNVERIFIED: release tags carry a version/ prefix, so an extractVersion rule is needed.
  default = "2026.8.6"
}

// Core project license is MIT (LICENSE file). authentik/enterprise/ has its own license and
// is UNVERIFIED for this image. Check before publishing.
variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/goauthentik/authentik"
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
  // UNVERIFIED: arm64 server build. Keep amd64 only until the upstream arm64 image is confirmed.
  platforms = [
    "linux/amd64"
  ]
}
