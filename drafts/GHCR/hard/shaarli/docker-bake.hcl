target "docker-metadata-action" {}

variable "APP" {
  default = "shaarli"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=shaarli/Shaarli versioning=semver
  default = "0.16.11"
}

// UNVERIFIED: no upstream checksum is published. Set this from the first verified download. The build fails while it is empty.
variable "SHAARLI_SHA256" {
  default = ""
}

variable "LICENSE" {
  default = "Zlib"
}

variable "SOURCE" {
  default = "https://github.com/shaarli/Shaarli"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SHAARLI_SHA256 = "${SHAARLI_SHA256}"
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
