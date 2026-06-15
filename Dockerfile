# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/powershell:lts-ubuntu-22.04

LABEL org.opencontainers.image.title="Vega Utility" \
      org.opencontainers.image.description="Lightweight utility image with kubectl, helm, and PowerShell for Kubernetes management" \
      org.opencontainers.image.authors="Archetypical Software" \
      org.opencontainers.image.vendor="Archetypical Software" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/ArchetypicalSoftware/vega-utility"

# TARGETARCH is set automatically by Docker BuildKit (amd64 or arm64)
ARG TARGETARCH=amd64
ARG K8S_VERSION=1.32.0

# Install minimal dependencies and Helm via the official GPG-signed apt repository
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg \
        apt-transport-https; \
    curl -fsSL https://baltocdn.com/helm/signing.asc \
        | gpg --dearmor -o /usr/share/keyrings/helm.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] \
https://baltocdn.com/helm/stable/debian/ all main" \
        > /etc/apt/sources.list.d/helm-stable-debian.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends helm; \
    rm -rf /var/lib/apt/lists/*

# Install kubectl with sha256 checksum verification
RUN set -eux; \
    curl -fsSL "https://dl.k8s.io/release/v${K8S_VERSION}/bin/linux/${TARGETARCH}/kubectl" \
        -o /tmp/kubectl; \
    curl -fsSL "https://dl.k8s.io/release/v${K8S_VERSION}/bin/linux/${TARGETARCH}/kubectl.sha256" \
        -o /tmp/kubectl.sha256; \
    echo "$(cat /tmp/kubectl.sha256)  /tmp/kubectl" | sha256sum --check; \
    install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl; \
    rm -f /tmp/kubectl /tmp/kubectl.sha256

# Create a dedicated non-root user for running workloads
RUN useradd -m -u 1000 -s /usr/bin/pwsh utility

USER utility
WORKDIR /home/utility

CMD ["pwsh"]

