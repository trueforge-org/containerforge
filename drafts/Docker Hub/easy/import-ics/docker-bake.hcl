target "docker-metadata-action" {}

variable "APP" {
  default = "import-ics"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/Vilhjalmr26/import_ics currentValue=main
  default = "ec04d6c113aa9014f2127639db9801a1fb4f9d3b"
}

variable "SUPERCRONIC_VERSION" {
  // renovate: datasource=github-releases depName=aptible/supercronic versioning=semver
  default = "v0.2.51"
}

// UNVERIFIED: upstream publishes no license. NOASSERTION until the maintainer confirms one.
variable "LICENSE" {
  default = "NOASSERTION"
}

variable "SOURCE" {
  default = "https://github.com/Vilhjalmr26/import_ics"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    SUPERCRONIC_VERSION = "${SUPERCRONIC_VERSION}"
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
