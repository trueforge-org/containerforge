target "docker-metadata-action" {}

variable "APP" {
  default = "stackedit"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=benweet/stackedit extractVersion=^v(?<version>.+)$ versioning=semver
  // UNVERIFIED: tags only (no releases), and it is not confirmed that 5.14.0 is the newest tag.
  default = "5.14.0"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/benweet/stackedit"
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
