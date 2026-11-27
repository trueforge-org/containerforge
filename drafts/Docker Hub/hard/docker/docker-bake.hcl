target "docker-metadata-action" {}

variable "APP" {
  default = "docker"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=moby/moby versioning=semver
  // UNVERIFIED: moby/moby tags may be "v29.10.0", which needs extractVersion=^v(?<version>.+)$. Also every tag needs a matching static tarball on download.docker.com.
  // Pinned at 29.10.0 by plan decision; 29.10.1 is newer on download.docker.com.
  default = "29.10.0"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/moby/moby"
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
