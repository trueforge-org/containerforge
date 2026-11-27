target "docker-metadata-action" {}

variable "APP" {
  default = "shlink-web-client"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=shlinkio/shlink-web-client versioning=semver
  default = "4.9.1"
}

variable "SHA256" {
  // UNVERIFIED: no upstream checksum is published. Compute the SHA-256 of
  // shlink-web-client_${VERSION}_dist.zip from the release asset and pin it here.
  default = ""
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/shlinkio/shlink-web-client"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SHA256 = "${SHA256}"
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
