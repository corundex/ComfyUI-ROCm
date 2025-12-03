# ROCm ComfyUI Dockerfile
# Based on AMD's official ROCm PyTorch container

FROM rocm/pytorch:rocm7.1.1_ubuntu24.04_py3.12_pytorch_release_2.9.1

# Set working directory
WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
  git \
  wget \
  curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


# Clone ComfyUI and checkout pinned version
RUN git clone https://github.com/comfyanonymous/ComfyUI.git \
  && cd ComfyUI \
  && git checkout v0.3.76

# Set ComfyUI as working directory
WORKDIR /workspace/ComfyUI

# Create necessary directories with separate commands
RUN mkdir -p /workspace/ComfyUI/models/checkpoints && \
  mkdir -p /workspace/ComfyUI/models/vae && \
  mkdir -p /workspace/ComfyUI/models/loras && \
  mkdir -p /workspace/ComfyUI/models/embeddings && \
  mkdir -p /workspace/ComfyUI/models/upscale_models && \
  mkdir -p /workspace/ComfyUI/models/controlnet && \
  mkdir -p /workspace/ComfyUI/output && \
  mkdir -p /workspace/ComfyUI/input && \
  mkdir -p /workspace/ComfyUI/custom_nodes

# Copy ROCm-tested requirements files
COPY docker/requirements_rocm.txt /workspace/

# Install Python dependencies using ROCm-compatible requirements
# These files have been tested on real AMD hardware and filter out packages that break ROCm
RUN pip install --no-cache-dir -r /workspace/requirements_rocm.txt

# Copy startup script, models config, and sample workflow
COPY docker/startup.sh /workspace/startup.sh
COPY docker/download_models.py /workspace/download_models.py
COPY docker/models.yaml /workspace/models.yaml
COPY docker/sample_workflow.json /workspace/ComfyUI/

# Make startup script executable
RUN chmod +x /workspace/startup.sh

# Environment variables for model download behavior
# MODEL_DOWNLOAD options:
#   "default"   - Download basic SD 1.5 model (default)
#   "all"       - Download full model set (SD 1.5, SDXL, ControlNet, etc.)
#   "realistic" - Download realistic photo models  
#   "none"      - Skip all downloads, use existing models only
#   Custom      - Any section name from models.conf
ENV MODEL_DOWNLOAD=none

# Expose ComfyUI port
EXPOSE 8188

# Health check to ensure ComfyUI is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8188/ || exit 1

# Use smart startup script that handles model downloads
CMD ["/workspace/startup.sh"]

