target "docker-metadata-action" {}

variable "APP" {
  default = "socials"
}

// UNVERIFIED: upstream has no releases or tags. Pinned to commit 2b7a17b, which has the same
// Dockerfile as main. Replace with the current main HEAD SHA before the first build.
// renovate: datasource=git-refs depName=https://github.com/diamkil/socials currentValue=main
variable "VERSION" {
  default = "2b7a17b519896cc18b775536d7f9016921df133a"
}

variable "LICENSE" {
  default = "ISC"
}

variable "SOURCE" {
  default = "https://github.com/diamkil/socials"
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
