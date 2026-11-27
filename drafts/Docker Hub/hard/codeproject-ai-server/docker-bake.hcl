target "docker-metadata-action" {}

variable "APP" {
  default = "codeproject-ai-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=codeproject/CodeProject.AI-Server versioning=loose
  // Tags are v-prefixed; the Dockerfile strips the v. 2.9.5 is used because it has both x64 and arm64 installers.
  default = "2.9.5"
}

variable "CPAI_SHA256_AMD64" {
  // UNVERIFIED placeholder: no checksum is published. Compute sha256 of the x64 zip and replace before building.
  default = "UNVERIFIED"
}

variable "CPAI_SHA256_ARM64" {
  // UNVERIFIED placeholder: compute sha256 of the arm64 zip and replace before building.
  default = "UNVERIFIED"
}

variable "LICENSE" {
  // SSPL-1.0 is not an OSI license. Call it out in the PR.
  default = "SSPL-1.0"
}

variable "SOURCE" {
  default = "https://github.com/codeproject/CodeProject.AI-Server"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    CPAI_SHA256_AMD64 = "${CPAI_SHA256_AMD64}"
    CPAI_SHA256_ARM64 = "${CPAI_SHA256_ARM64}"
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
