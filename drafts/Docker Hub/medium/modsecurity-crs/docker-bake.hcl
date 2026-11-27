target "docker-metadata-action" {}

variable "APP" {
  default = "modsecurity-crs"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=coreruleset/coreruleset versioning=semver
  default = "4.31.0"
}

// UNVERIFIED: this is the CRS license. Confirm the ModSecurity engine (libapache2-mod-security2) license before merge.
variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/coreruleset/coreruleset"
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
