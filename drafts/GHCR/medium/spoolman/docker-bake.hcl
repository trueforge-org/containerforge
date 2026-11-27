target "docker-metadata-action" {}

variable "APP" {
  default = "spoolman"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Donkie/Spoolman versioning=semver
  default = "0.27.1"
}

// sha256 of spoolman.zip for VERSION (release asset digest). Update it by hand together with VERSION.
variable "SPOOLMAN_SHA256" {
  default = "77ba10fa505a42cef606eabec1a7c9a5b93c51dc40067456a29a7d9480ef27d6"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/Donkie/Spoolman"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SPOOLMAN_SHA256 = "${SPOOLMAN_SHA256}"
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
