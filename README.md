# Vega Utility

[![Monthly Docker Build](https://github.com/ArchetypicalSoftware/vega-utility/actions/workflows/build-release.yaml/badge.svg)](https://github.com/ArchetypicalSoftware/vega-utility/actions/workflows/build-release.yaml)
[![Last Build](https://img.shields.io/github/last-commit/ArchetypicalSoftware/vega-utility/main?label=last%20build)](https://github.com/ArchetypicalSoftware/vega-utility/actions/workflows/build-release.yaml)
[![Docker Pulls](https://img.shields.io/docker/pulls/archetypicalsoftware/vega-utility)](https://hub.docker.com/r/archetypicalsoftware/vega-utility)

## Supported Kubernetes Versions

The five most recent Kubernetes minor releases are tracked and rebuilt automatically every month. Each tag is updated with the latest stable patch for that minor version (e.g. `v1.32` always points to the latest `1.32.x` release).

[![k8s v1.32](https://img.shields.io/badge/k8s-v1.32-blue?logo=kubernetes)](https://hub.docker.com/r/archetypicalsoftware/vega-utility/tags)
[![k8s v1.31](https://img.shields.io/badge/k8s-v1.31-blue?logo=kubernetes)](https://hub.docker.com/r/archetypicalsoftware/vega-utility/tags)
[![k8s v1.30](https://img.shields.io/badge/k8s-v1.30-blue?logo=kubernetes)](https://hub.docker.com/r/archetypicalsoftware/vega-utility/tags)
[![k8s v1.29](https://img.shields.io/badge/k8s-v1.29-blue?logo=kubernetes)](https://hub.docker.com/r/archetypicalsoftware/vega-utility/tags)
[![k8s v1.28](https://img.shields.io/badge/k8s-v1.28-blue?logo=kubernetes)](https://hub.docker.com/r/archetypicalsoftware/vega-utility/tags)

## Supported Platforms

| Platform | Architecture |
|----------|-------------|
| `linux/amd64` | x86-64 (standard cloud/server) |
| `linux/arm64` | ARM 64-bit (Apple M-series, AWS Graviton, Raspberry Pi 4+) |

## Overview

The Vega Utility is a Docker base image that provides essential Kubernetes tools in a PowerShell environment. This utility image combines PowerShell Core, kubectl (Kubernetes CLI), and Helm (Kubernetes package manager) to create a comprehensive toolset for building, deploying, and managing Vega Atlas applications and other Kubernetes-based solutions.

## What's Included

- **PowerShell Core** (`pwsh`): Cross-platform PowerShell environment for scripting and automation
- **kubectl**: Official Kubernetes command-line tool – installed at the latest stable patch for each tracked minor version, with sha256 checksum verification
- **Helm**: Kubernetes package manager – installed from the official Helm GPG-signed apt repository
- **curl**: HTTP client for API interactions and downloads

## Security

- **Checksum verification**: `kubectl` is verified against its published sha256 before installation.
- **Signed package repository**: Helm is installed from the official Helm apt repository, verified with GPG.
- **Non-root user**: The container runs as a non-privileged `utility` user (uid 1000).
- **Monthly rebuilds**: Images are rebuilt on the 1st of every month so that OS-level security patches from the base image are always applied.
- **Trivy scanning**: After each build the published `latest` image is scanned with [Trivy](https://github.com/aquasecurity/trivy). The workflow fails if any **CRITICAL** vulnerability with a known fix is found.
- **Minimal footprint**: Only `curl`, `ca-certificates`, `gnupg`, `apt-transport-https`, and Helm are added; no unnecessary packages are installed.

## Intended Use Cases

This utility image is designed for:

1. **CI/CD Pipelines**: Use in GitHub Actions, GitLab CI, or other CI/CD systems for Kubernetes deployments
2. **Vega Atlas Development**: Building and deploying Vega Atlas components with PowerShell automation
3. **Kubernetes Administration**: Running kubectl commands and Helm operations in a consistent environment
4. **Infrastructure as Code**: Executing PowerShell scripts that interact with Kubernetes clusters
5. **Development Workflows**: Local development containers for Kubernetes application development

## Usage

### Docker Hub

Pull the latest image (tracks the newest supported Kubernetes minor version):

```bash
docker pull archetypicalsoftware/vega-utility:latest
```

Pull an image for a specific Kubernetes patch release:

```bash
docker pull archetypicalsoftware/vega-utility:v1.32.5
```

### In GitHub Actions

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: archetypicalsoftware/vega-utility:latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Kubernetes
        run: |
          echo "${{ secrets.KUBECONFIG }}" | base64 -d > ~/.kube/config
          pwsh -File ./deploy-vega.ps1
```

### In Docker Compose

```yaml
services:
  vega-utility:
    image: archetypicalsoftware/vega-utility:latest
    volumes:
      - ~/.kube:/home/utility/.kube:ro
      - ./scripts:/scripts
    working_dir: /scripts
    command: pwsh -File ./deploy.ps1
```

### Interactive Usage

```bash
docker run -it --rm \
  -v ~/.kube:/home/utility/.kube:ro \
  -v "$(pwd)":/workspace \
  -w /workspace \
  archetypicalsoftware/vega-utility:latest
```

Inside the container you have access to `pwsh`, `kubectl`, `helm`, and `curl`.

### Example PowerShell Script

```powershell
#!/usr/bin/env pwsh
Write-Host "Deploying Vega Atlas components..."

kubectl cluster-info

helm repo add vega https://charts.vega.example.com
helm repo update
helm upgrade --install vega-atlas vega/atlas --namespace vega --create-namespace

Write-Host "Deployment completed successfully!"
```

## Testing

### Run the test suite locally

Build the image first, then run the shell smoke-test:

```bash
docker build --build-arg K8S_VERSION=1.32.5 -t vega-utility:test .
./tests/test-container.sh vega-utility:test
```

Or run the PowerShell tests directly inside the container:

```bash
docker run --rm -v "$(pwd)/tests:/tests" vega-utility:test pwsh /tests/test-tools.ps1
```

### CI test job

The `test` job in [build-release.yaml](.github/workflows/build-release.yaml) spins up a container using the freshly-pushed image and executes `tests/test-tools.ps1` inside it, verifying every tool before the `latest` tag is updated.

## Building Custom Images

```dockerfile
FROM archetypicalsoftware/vega-utility:latest

# Add your custom tools or scripts
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.ps1

WORKDIR /scripts
```

## Image Updates

Docker images are rebuilt automatically on the **1st of every month** for the five most-recent Kubernetes minor releases. Rebuilding picks up the latest OS security patches from the base image and the latest kubectl patch release for each tracked minor version. The `latest` tag always points to the newest supported Kubernetes version.

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.
