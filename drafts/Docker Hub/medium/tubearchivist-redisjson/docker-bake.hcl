target "docker-metadata-action" {}

variable "APP" {
  default = "tubearchivist-redisjson"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=redis/redis versioning=semver
  default = "8.12.0"
}

// UNVERIFIED: placeholder. Replace with the exact package string from `apt-cache policy redis-server` at build time.
variable "PACKAGE_VERSION" {
  default = "8.12.0-UNVERIFIED"
}

// UNVERIFIED: Redis 8 is tri-licensed (RSALv2/SSPLv1/AGPLv3). AGPL-3.0 is the planning choice; confirm before merge.
variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/redis/redis"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    PACKAGE_VERSION = "${PACKAGE_VERSION}"
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
