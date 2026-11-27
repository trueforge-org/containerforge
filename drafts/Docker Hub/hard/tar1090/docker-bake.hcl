target "docker-metadata-action" {}

variable "APP" {
  default = "tar1090"
}

// Upstream has no releases. VERSION is the commit that holds the tar1090 "version" file (3.14.1827).
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/wiedehopf/tar1090 versioning=loose
  default = "9e1b6a48dcb7c4104f3f967f808df45e8f53d44c"
}

// UNVERIFIED: pin a wiedehopf/readsb commit SHA here. An empty value builds the default branch.
variable "READSB_REF" {
  default = ""
}

variable "LICENSE" {
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/wiedehopf/tar1090"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    READSB_REF = "${READSB_REF}"
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
