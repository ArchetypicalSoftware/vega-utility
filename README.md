# Vega Utility

[![Docker Build Status](https://github.com/ArchetypicalSoftware/vega-utility/workflows/Monthly%20Docker%20Build/badge.svg)](https://github.com/ArchetypicalSoftware/vega-utility/actions/workflows/build-release.yaml)
[![Last Build](https://img.shields.io/github/last-commit/ArchetypicalSoftware/vega-utility/main?label=last%20build)](https://github.com/ArchetypicalSoftware/vega-utility/actions/workflows/build-release.yaml)

## Supported Kubernetes Versions

[![k8s v1.31.0](https://img.shields.io/badge/k8s-v1.31.0-blue?logo=kubernetes)](https://hub.docker.com/r/archetypicalsoftware/vega-utility/tags)
[![k8s v1.30.0](https://img.shields.io/badge/k8s-v1.30.0-blue?logo=kubernetes)](https://hub.docker.com/r/archetypicalsoftware/vega-utility/tags)
[![k8s v1.29.0](https://img.shields.io/badge/k8s-v1.29.0-blue?logo=kubernetes)](https://hub.docker.com/r/archetypicalsoftware/vega-utility/tags)
[![k8s v1.28.0](https://img.shields.io/badge/k8s-v1.28.0-blue?logo=kubernetes)](https://hub.docker.com/r/archetypicalsoftware/vega-utility/tags)

## Overview

The Vega Utility is a Docker base image that provides essential Kubernetes tools in a PowerShell environment. This utility image combines PowerShell Core, kubectl (Kubernetes CLI), and Helm (Kubernetes package manager) to create a comprehensive toolset for building, deploying, and managing Vega Atlas applications and other Kubernetes-based solutions.

## What's Included

- **PowerShell Core**: Cross-platform PowerShell environment for scripting and automation
- **kubectl**: Official Kubernetes command-line tool for cluster management
- **Helm**: Kubernetes package manager for deploying and managing applications
- **curl**: HTTP client for API interactions and downloads

## Intended Use Cases

This utility image is designed for:

1. **CI/CD Pipelines**: Use in GitHub Actions, GitLab CI, or other CI/CD systems for Kubernetes deployments
2. **Vega Atlas Development**: Building and deploying Vega Atlas components with PowerShell automation
3. **Kubernetes Administration**: Running kubectl commands and Helm operations in a consistent environment
4. **Infrastructure as Code**: Executing PowerShell scripts that interact with Kubernetes clusters
5. **Development Workflows**: Local development containers for Kubernetes application development

## Usage

### Docker Hub

Pull the latest image:
```bash
docker pull archetypicalsoftware/vega-utility:latest
```

Pull a specific Kubernetes version:
```bash
docker pull archetypicalsoftware/vega-utility:v1.30.0
```

### In Docker Compose

```yaml
version: '3.8'
services:
  vega-utility:
    image: archetypicalsoftware/vega-utility:latest
    volumes:
      - ~/.kube:/root/.kube:ro
      - ./scripts:/scripts
    working_dir: /scripts
    command: pwsh -Command "& ./deploy.ps1"
```

### In GitHub Actions

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: archetypicalsoftware/vega-utility:v1.30.0
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Kubernetes
        run: |
          # Configure kubectl context
          echo "${{ secrets.KUBECONFIG }}" | base64 -d > ~/.kube/config
          
          # Run PowerShell deployment script
          pwsh -Command "& ./deploy-vega.ps1"
```

### Interactive Usage

```bash
# Run an interactive PowerShell session
docker run -it --rm \
  -v ~/.kube:/root/.kube:ro \
  -v $(pwd):/workspace \
  -w /workspace \
  archetypicalsoftware/vega-utility:latest

# In the container, you can now use:
# - pwsh for PowerShell
# - kubectl for Kubernetes operations  
# - helm for package management
```

### Example PowerShell Script

```powershell
#!/usr/bin/env pwsh

# Example Vega deployment script
Write-Host "Deploying Vega Atlas components..."

# Check cluster connectivity
kubectl cluster-info

# Deploy using Helm
helm repo add vega https://charts.vega.example.com
helm repo update
helm upgrade --install vega-atlas vega/atlas --namespace vega --create-namespace

Write-Host "Deployment completed successfully!"
```

## Building Custom Images

If you need to customize the image:

```dockerfile
FROM archetypicalsoftware/vega-utility:v1.30.0

# Add your custom tools or scripts
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.ps1

WORKDIR /scripts
```

## Image Updates

Docker images are automatically built monthly on the 1st of each month with the latest stable Kubernetes versions. Each image is tagged with the corresponding Kubernetes version (e.g., `v1.30.0`) and the latest version is also tagged as `latest`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
