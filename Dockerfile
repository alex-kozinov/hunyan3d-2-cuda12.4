FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TORCH_CUDA_ARCH_LIST="8.6+PTX" \
    HF_HUB_ENABLE_HF_TRANSFER=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1

# --------------------------------------------------------
# 1. Base system packages
# --------------------------------------------------------
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    git tmux wget curl ca-certificates \
    libgl1-mesa-glx libglib2.0-0 libopengl0 \
    ffmpeg \
    build-essential pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Make python/pip the default commands
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1 && \
    python -m pip install --upgrade pip setuptools wheel

# --------------------------------------------------------
# 2. Install PyTorch (2.6.0 + CUDA 12.4 runtime)
# --------------------------------------------------------
RUN pip install \
    "torch==2.6.0+cu124" \
    "torchvision==0.21.0+cu124" \
    --index-url https://download.pytorch.org/whl/cu124

# --------------------------------------------------------
# 3. HuggingFace + ускоренная загрузка моделей
# --------------------------------------------------------
RUN pip install -U "huggingface_hub[cli]" hf_transfer

# --------------------------------------------------------
# 4. JupyterLab (и при желании ipykernel)
# --------------------------------------------------------
RUN pip install jupyterlab ipykernel && \
    python -m ipykernel install --user --name py310 --display-name "Python 3.10 (CUDA 12.x)"

# --------------------------------------------------------
# 5. Set up workspace and prepare project
# --------------------------------------------------------
WORKDIR /workspace

# Clone Hunyuan3D-2 repository into the image (shallow clone to avoid HTTP/2 issues)
RUN git config --global http.postBuffer 524288000 && \
    git config --global http.version HTTP/1.1 && \
    git clone --depth 1 https://github.com/Tencent-Hunyuan/Hunyuan3D-2.git /workspace/Hunyuan3D-2

WORKDIR /workspace/Hunyuan3D-2

# Install Python dependencies of the project
RUN python -m pip install -r requirements.txt

# Build and install custom rasterizer
RUN cd hy3dgen/texgen/custom_rasterizer && \
    python setup.py install

# Build and install differentiable renderer (mesh processor)
RUN cd hy3dgen/texgen/differentiable_renderer && \
    python setup.py install
    
# --------------------------------------------------------
# 6. Start Script / entrypoint
# --------------------------------------------------------
COPY scripts/start.sh /start.sh
RUN chmod 755 /start.sh

WORKDIR /workspace
CMD ["/start.sh"]
