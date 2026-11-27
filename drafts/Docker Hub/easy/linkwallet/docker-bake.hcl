target "docker-metadata-action" {}

variable "APP" {
  default = "linkwallet"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=tardisx/linkwallet versioning=semver
  // UNVERIFIED: repo is archived and moved to code.ppl.town; this datasource sees no newer release
  default = "0.1.1"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/tardisx/linkwallet"
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
