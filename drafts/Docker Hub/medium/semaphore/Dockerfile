FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# renovate: datasource=github-releases depName=semaphoreui/semaphore versioning=semver
ARG VERSION=2.20.23
# renovate: datasource=github-releases depName=opentofu/opentofu
ARG TOFU_VERSION=1.13.10
# renovate: datasource=github-releases depName=hashicorp/terraform
ARG TERRAFORM_VERSION=1.17.2
# renovate: datasource=github-releases depName=gruntwork-io/terragrunt
ARG TERRAGRUNT_VERSION=0.99.5
# renovate: datasource=pypi depName=ansible
ARG ANSIBLE_VERSION=13.8.0
ARG TARGETARCH

ENV \
    HOME=/tmp \
    PIP_CACHE_DIR=/tmp/pip \
    ANSIBLE_LOCAL_TEMP=/tmp/ansible \
    ANSIBLE_REMOTE_TEMP=/tmp/ansible \
    PATH="/app/ansible-venv/bin:${PATH}"

USER root
WORKDIR /app

# Install runtime packages not already in the base.
# UNVERIFIED: apt package versions; pin them once checked against the image.
# mysql-client is left out: the database is external and configured at runtime.
RUN apt-get update && apt-get install -y --no-install-recommends \
        bash \
        curl \
        git \
        gnupg \
        jq \
        openssh-client \
        python3 \
        python3-venv \
        rsync \
        sshpass \
        tar \
        tzdata \
        unzip \
        wget \
        zip \
    && rm -rf /var/lib/apt/lists/*

# Semaphore server, verified against the sha256 values in semaphore_2.20.23_checksums.txt.
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) SEMAPHORE_SHA256="89cbee983255534e167f140b8c58b4e5973b761afdeeea3fd81a5809ff6a8318" ;; \
        arm64) SEMAPHORE_SHA256="3a6cd34f8083ceb1f51953ae9d2022c8b82e232d9fa7789f2619f55a1b5db4c5" ;; \
        *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    mkdir -p /tmp/dl; \
    curl -fsSL -o /tmp/dl/semaphore.tar.gz \
        "https://github.com/semaphoreui/semaphore/releases/download/v${VERSION}/semaphore_${VERSION}_linux_${TARGETARCH}.tar.gz"; \
    echo "${SEMAPHORE_SHA256}  /tmp/dl/semaphore.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/dl/semaphore.tar.gz -C /tmp/dl semaphore; \
    install -m 0755 /tmp/dl/semaphore /usr/local/bin/semaphore; \
    rm -rf /tmp/dl/*

# Bundled IaC tools. UNVERIFIED: upstream checksum files for these are not checked yet.
# Add sha256 verification here once the checksum sources are confirmed (do not skip).
RUN set -eux; \
    mkdir -p /tmp/dl; \
    curl -fsSL -o /tmp/dl/tofu.tar.gz \
        "https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_${TARGETARCH}.tar.gz"; \
    tar -xzf /tmp/dl/tofu.tar.gz -C /tmp/dl tofu; \
    install -m 0755 /tmp/dl/tofu /usr/local/bin/tofu; \
    curl -fsSL -o /tmp/dl/terraform.zip \
        "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip"; \
    unzip -q -o /tmp/dl/terraform.zip -d /tmp/dl terraform; \
    install -m 0755 /tmp/dl/terraform /usr/local/bin/terraform; \
    curl -fsSL -o /usr/local/bin/terragrunt \
        "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_${TARGETARCH}"; \
    chmod 0755 /usr/local/bin/terragrunt; \
    rm -rf /tmp/dl/*

# Ansible venv is built at build time and is read-only at runtime.
RUN python3 -m venv /app/ansible-venv \
    && /app/ansible-venv/bin/pip install --no-cache-dir \
        "ansible==${ANSIBLE_VERSION}" \
        boto3 \
        botocore \
        paramiko \
        pywinrm \
        requests

# License of the software in the image (upstream publishes no checksum for this file).
RUN mkdir -p /usr/share/licenses/semaphore \
    && curl -fsSL -o /usr/share/licenses/semaphore/LICENSE \
        "https://raw.githubusercontent.com/semaphoreui/semaphore/v${VERSION}/LICENSE" \
    && chown -R root:root /app && chmod -R 755 /app \
    && rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /
WORKDIR /config

EXPOSE 3000
VOLUME /config
