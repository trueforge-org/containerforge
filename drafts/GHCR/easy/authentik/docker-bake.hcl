target "docker-metadata-action" {}

// UNVERIFIED: this is the ldap outpost only. The proxy and radius outposts are separate apps, not written yet.
// The release tag is version/<VERSION>. Confirm that renovate's regex strips the prefix (extractVersion).
variable "APP" {
  default = "authentik-ldap"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=goauthentik/authentik versioning=loose
  default = "2026.8.6"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/goauthentik/authentik"
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
