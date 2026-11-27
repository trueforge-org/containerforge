target "docker-metadata-action" {}

variable "APP" {
  default = "llalon-github-backup"
}

variable "VERSION" {
  // Wrapper version. Upstream has no releases; bump with GITHUB_BACKUP_REF.
  default = "0.1.0"
}

variable "GITHUB_BACKUP_REF" {
  // renovate: datasource=git-refs depName=https://github.com/abusesa/github-backup versioning=loose
  // UNVERIFIED: the upstream commit SHA is not recorded in the plan. Replace `master` with a verified commit SHA.
  default = "master"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/abusesa/github-backup"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    GITHUB_BACKUP_REF = "${GITHUB_BACKUP_REF}"
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
