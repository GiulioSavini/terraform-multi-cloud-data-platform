FROM hashicorp/terraform:1.9 AS terraform
FROM alpine:3.20

LABEL maintainer="giulio"
LABEL description="Multi-Cloud Data Platform Terraform Workspace"

# Install base tools
RUN apk add --no-cache \
    bash \
    curl \
    git \
    jq \
    make \
    python3 \
    py3-pip \
    openssh-client \
    ca-certificates \
    gnupg \
    unzip \
    wget \
    docker-cli

# Copy Terraform binary from official image
COPY --from=terraform /bin/terraform /usr/local/bin/terraform

# Install Terragrunt
ARG TERRAGRUNT_VERSION=0.67.4
RUN wget -q "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" \
    -O /usr/local/bin/terragrunt && \
    chmod +x /usr/local/bin/terragrunt

# Install tflint
ARG TFLINT_VERSION=0.53.0
RUN wget -q "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip" \
    -O /tmp/tflint.zip && \
    unzip /tmp/tflint.zip -d /usr/local/bin && \
    rm /tmp/tflint.zip

# Install tfsec
ARG TFSEC_VERSION=1.28.11
RUN wget -q "https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64" \
    -O /usr/local/bin/tfsec && \
    chmod +x /usr/local/bin/tfsec

# Install checkov
RUN pip3 install --no-cache-dir --break-system-packages checkov

# Install AWS CLI v2
RUN curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
    unzip -q /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/awscliv2.zip /tmp/aws

# Install Azure CLI
RUN apk add --no-cache --virtual .build-deps gcc musl-dev python3-dev libffi-dev && \
    pip3 install --no-cache-dir --break-system-packages azure-cli && \
    apk del .build-deps

# Install Google Cloud SDK
ARG GCLOUD_VERSION=494.0.0
RUN curl -sL "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GCLOUD_VERSION}-linux-x86_64.tar.gz" \
    | tar -xz -C /opt && \
    /opt/google-cloud-sdk/install.sh --quiet --path-update true && \
    ln -s /opt/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud && \
    ln -s /opt/google-cloud-sdk/bin/gsutil /usr/local/bin/gsutil && \
    ln -s /opt/google-cloud-sdk/bin/bq /usr/local/bin/bq

# Install pre-commit
RUN pip3 install --no-cache-dir --break-system-packages pre-commit

# Set working directory
WORKDIR /workspace

# Shell configuration
RUN echo 'alias tf="terraform"' >> /root/.bashrc && \
    echo 'alias tg="terragrunt"' >> /root/.bashrc && \
    echo 'alias ll="ls -la"' >> /root/.bashrc && \
    echo 'export PS1="\[\033[1;36m\]data-platform\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]$ "' >> /root/.bashrc

ENTRYPOINT ["/bin/bash"]
