target "docker-metadata-action" {}

variable "APP" {
  default = "urban-terror"
}

variable "VERSION" {
  // UNVERIFIED: no versioned release source. 4.3 is the game version from the upstream download path (urt/43).
  // No renovate annotation until a versioned source exists.
  default = "4.3"
}

variable "SHA256" {
  // UNVERIFIED: placeholder. Compute the sha256 of UrbanTerror43_ded.tar.gz once and pin it here.
  // The build fails until this is set.
  default = "UNVERIFIED-COMPUTE-SHA256"
}

variable "LICENSE" {
  // UNVERIFIED: no license is stated upstream. Do not invent an SPDX value.
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://www.urbanterror.info/home/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
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
  // arm64 is not built: the server binary is x86_64 only, and the ioq3 compile is unvalidated.
  platforms = [
    "linux/amd64"
  ]
}
