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
ARG HELM_VERSION=3.17.3

# Install minimal dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates; \
    rm -rf /var/lib/apt/lists/*

# Install Helm from official binary release with sha256 checksum verification
RUN set -eux; \
    curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" \
        -o /tmp/helm.tar.gz; \
    curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz.sha256sum" \
        -o /tmp/helm.sha256; \
    echo "$(awk '{print $1}' /tmp/helm.sha256)  /tmp/helm.tar.gz" | sha256sum --check; \
    tar -xzf /tmp/helm.tar.gz -C /tmp; \
    install -o root -g root -m 0755 /tmp/linux-${TARGETARCH}/helm /usr/local/bin/helm; \
    rm -rf /tmp/helm.tar.gz /tmp/helm.sha256 /tmp/linux-${TARGETARCH}

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

