target "docker-metadata-action" {}

variable "APP" {
  default = "baserow"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=baserow/baserow versioning=semver
  default = "2.4.3"
}

// UNVERIFIED: the premium/ and enterprise/ directories carry a separate Baserow license. They are not shipped here, so MIT covers the core only.
variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/baserow/baserow"
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
