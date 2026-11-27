target "docker-metadata-action" {}

variable "APP" {
  default = "kms"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Py-KMS-Organization/py-kms versioning=loose
  default = "1.0.1"
}

// Tag commit. Renovate bumps VERSION only, so COMMIT and SHA256 need a manual update.
variable "COMMIT" {
  default = "b0e1615dec06293c927625006a99e6ec54a001aa"
}

// UNVERIFIED: sha256 of the source archive for COMMIT. Not yet recorded. Set it from the first build.
variable "SHA256" {
  default = ""
}

variable "LICENSE" {
  default = "Unlicense"
}

variable "SOURCE" {
  default = "https://github.com/Py-KMS-Organization/py-kms"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    COMMIT = "${COMMIT}"
    SHA256 = "${SHA256}"
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
