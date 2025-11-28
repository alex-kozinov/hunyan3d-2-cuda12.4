FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TORCH_CUDA_ARCH_LIST="8.6+PTX"

# --------------------------------------------------------
# 1. Base system packages
# --------------------------------------------------------
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    git tmux wget \
    libgl1-mesa-glx libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Make python/pip the default commands
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# --------------------------------------------------------
# 2. Install PyTorch with CUDA 12.1 support
# --------------------------------------------------------
RUN pip install --upgrade pip setuptools wheel
RUN pip install "torch>=2.3" torchvision --index-url https://download.pytorch.org/whl/cu121

# --------------------------------------------------------
# 3. Install JupyterLab
# --------------------------------------------------------
RUN pip install jupyterlab

# --------------------------------------------------------
# 4. Clone some project repository
# --------------------------------------------------------
WORKDIR /workspace

# --------------------------------------------------------
# 5. Install project dependencies
# --------------------------------------------------------


# --------------------------------------------------------
# 6. Default working directory and entrypoint
# --------------------------------------------------------
# Start Script
COPY scripts/start.sh /start.sh
RUN chmod 755 /start.sh
WORKDIR /workspace
CMD ["/start.sh"]
