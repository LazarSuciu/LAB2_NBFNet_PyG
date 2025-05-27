FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-runtime

# Set container entrypoint (bash shell)
CMD ["/bin/bash"]

# Enables color-coded build logs to make debugging easier
ENV BUILDKIT_COLORS=run=green:warning=yellow:error=red:cancel=cyan

# Set initial working directory (temporary)
WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    git-lfs \
    curl \
    python3-pip \
    python3-dev \
    build-essential \
    wget \
    unzip \
    sudo \
    nano \
    net-tools \
    jq \
    && rm -rf /var/lib/apt/lists/*
    
# Copy requirements.txt into the container's /workspace directory
COPY ./workspace/requirements.txt /workspace/requirements.txt

# Install dependencies from requirements.txt
RUN pip install -r /workspace/requirements.txt

# Install PyTorch Geometric dependencies
RUN pip install pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv -f https://data.pyg.org/whl/torch-2.6.0+cu124.html

# Remove requirements.txt after install
RUN rm /workspace/requirements.txt

# ipykernel is needed for jupyter notebooks
RUN pip install --upgrade --force-reinstall ipykernel

# Clone forked PyG repo from github
RUN git clone https://github.com/LazarSuciu/pytorch_geometric.git 

# change to PyG directory
WORKDIR /workspace/pytorch_geometric

# Install PyG in editable mode
RUN pip install -e ".[dev,full]"

# Run separately in continer to insure CUDA access
# Run tests
# RUN pytest test --disable-warnings -m "not cuda"

# Install pre-commit hooks
RUN pip install pre-commit && pre-commit install

# Upgrade pip and install essential Python packages
RUN pip install --upgrade pip setuptools wheel

# Copy devcontainer.json into the container
COPY ./.devcontainer /workspace/.devcontainer

# Make the preinstall_vscode.sh script executable
RUN chmod +x /workspace/.devcontainer/preinstall_vscode.sh

# Install VS Code Server inside the container
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install VS Code extensions
ARG VSCODE_COMMIT_HASH
RUN /workspace/.devcontainer/preinstall_vscode.sh $VSCODE_COMMIT_HASH /workspace/.devcontainer/devcontainer.json

# Clean up
RUN rm -rf /var/lib/apt/lists/*
