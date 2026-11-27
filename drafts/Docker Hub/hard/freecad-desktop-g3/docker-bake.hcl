target "docker-metadata-action" {}

variable "APP" {
  default = "freecad-desktop-g3"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=FreeCAD/FreeCAD versioning=loose
  default = "1.1.4"
}

// UNVERIFIED: the sha256 values of the AppImage files of this version (published next to each AppImage). Set them before the first build; the build fails while they are empty.
variable "FREECAD_SHA256_AMD64" {
  default = ""
}

variable "FREECAD_SHA256_ARM64" {
  default = ""
}

// UNVERIFIED: FreeCAD is documented as LGPL-2.0-or-later; confirm from the release.
variable "LICENSE" {
  default = "LGPL-2.1-or-later"
}

variable "SOURCE" {
  default = "https://github.com/FreeCAD/FreeCAD"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    FREECAD_SHA256_AMD64 = "${FREECAD_SHA256_AMD64}"
    FREECAD_SHA256_ARM64 = "${FREECAD_SHA256_ARM64}"
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
