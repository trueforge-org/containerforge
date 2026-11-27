target "docker-metadata-action" {}

variable "APP" {
  default = "tandoor-recipes"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=TandoorRecipes/recipes versioning=semver
  default = "2.7.8"
}

variable "LICENSE" {
  // UNVERIFIED: GitHub reports NOASSERTION. LICENSE.md is a Commons Clause condition, not a plain SPDX id. Set the real value once confirmed.
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/TandoorRecipes/recipes"
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
