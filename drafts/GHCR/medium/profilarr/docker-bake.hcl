target "docker-metadata-action" {}

variable "APP" {
  default = "profilarr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Dictionarry-Hub/profilarr versioning=semver
  default = "2.3.1"
}

variable "DENO_VERSION" {
  // renovate: datasource=github-releases depName=denoland/deno versioning=semver
  default = "2.9.8"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/Dictionarry-Hub/profilarr"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    DENO_VERSION = "${DENO_VERSION}"
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
