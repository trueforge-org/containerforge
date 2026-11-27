target "docker-metadata-action" {}

variable "APP" {
  default = "post-recording"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=erikkaashoek/Comskip versioning=loose extractVersion=^V(?<version>.+)$
  default = "0.83"
}

// UNVERIFIED: no checksum is published upstream. Set this to the sha256 of https://github.com/erikkaashoek/Comskip/archive/refs/tags/V${VERSION}.tar.gz before the first build.
variable "COMSKIP_SHA256" {
  default = ""
}

// UNVERIFIED: comchap is not versioned and has no release. Pin a commit of BrettSheleski/comchap before the first build.
variable "COMCHAP_COMMIT" {
  default = ""
}

// UNVERIFIED: confirm from the LICENSE file of the Comskip tarball.
variable "LICENSE" {
  default = "GPL-2.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/erikkaashoek/Comskip/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    COMSKIP_SHA256 = "${COMSKIP_SHA256}"
    COMCHAP_COMMIT = "${COMCHAP_COMMIT}"
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
