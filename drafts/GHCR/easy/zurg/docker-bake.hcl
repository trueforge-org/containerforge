target "docker-metadata-action" {}

variable "APP" {
  default = "zurg"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=debridmediamanager/zurg-public versioning=semver
  default = "1.0.0"
}

variable "LICENSE" {
  // BLOCKER: no licence is published for the zurg binary (plan section 10). Replace with the confirmed
  // licence before merging; this placeholder must not ship.
  default = "UNLICENSED-PENDING"
}

variable "SOURCE" {
  default = "https://github.com/debridmediamanager/zurg-public"
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
