FROM mcr.microsoft.com/powershell
LABEL Author="Archetypical Software" \
      Maintainer="Archetypical Software" \
      Description="Utility image for Vega" \
      Vendor="Archetypical Software" \
      Version="1.0" \
      License="MIT" \
      Repository="https://github.com/ArchetypicalSoftware/vega-utility"



ARG K8sVersion=1.30.0

# Install Curl
RUN apt-get update && apt-get install -y curl

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/${K8sVersion}/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm get_helm.sh

