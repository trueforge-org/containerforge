target "docker-metadata-action" {}

variable "APP" {
  default = "lancache-dns"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/lancachenet/lancache-dns versioning=loose
  // UNVERIFIED: 6b4b60e is the commit of the fetched Dockerfile, not confirmed as current master HEAD
  default = "6b4b60e"
}

variable "DNSTOOL_REF" {
  // renovate: datasource=git-refs depName=https://github.com/lancachenet/dnstool versioning=loose
  // UNVERIFIED: branch only, pin to a commit once read
  default = "master"
}

variable "CACHE_DOMAINS_REF" {
  // renovate: datasource=git-refs depName=https://github.com/uklans/cache-domains versioning=loose
  // UNVERIFIED: branch only, pin to a commit once read
  default = "master"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/lancachenet/lancache-dns"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    DNSTOOL_REF = "${DNSTOOL_REF}"
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
