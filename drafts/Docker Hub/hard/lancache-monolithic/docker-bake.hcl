target "docker-metadata-action" {}

variable "APP" {
  default = "lancache-monolithic"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/lancachenet/monolithic versioning=loose
  // Upstream publishes no releases or tags. Pinned to the commit the overlay was ported from (context/dockerfile-3f43cc7.md).
  default = "3f43cc7"
}

variable "CACHE_DOMAINS_REF" {
  // renovate: datasource=git-refs depName=https://github.com/uklans/cache-domains versioning=loose
  // UNVERIFIED: no commit SHA is recorded in the plan. Replace `master` with a verified commit SHA.
  default = "master"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/lancachenet/monolithic"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    CACHE_DOMAINS_REF = "${CACHE_DOMAINS_REF}"
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
