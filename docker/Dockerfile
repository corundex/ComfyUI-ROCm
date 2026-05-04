# ROCm ComfyUI Dockerfile
# Based on AMD's official ROCm PyTorch container

FROM rocm/pytorch:rocm7.2.2_ubuntu24.04_py3.12_pytorch_release_2.10.0

# Set working directory
WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
  git \
  wget \
  curl \
  ffmpeg \
  libgl1 \
  libglib2.0-0 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Clone ComfyUI and checkout pinned version
RUN git clone https://github.com/comfyanonymous/ComfyUI.git \
  && cd ComfyUI \
  && git checkout v0.19.3

# Set ComfyUI as working directory
WORKDIR /workspace/ComfyUI

# Create necessary directories
RUN mkdir -p \
  /workspace/ComfyUI/models/checkpoints \
  /workspace/ComfyUI/models/vae \
  /workspace/ComfyUI/models/loras \
  /workspace/ComfyUI/models/embeddings \
  /workspace/ComfyUI/models/upscale_models \
  /workspace/ComfyUI/models/controlnet \
  /workspace/ComfyUI/output \
  /workspace/ComfyUI/input \
  /workspace/ComfyUI/custom_nodes

# Install onnxruntime_migraphx — ROCm 7.x replacement for onnxruntime_rocm
# AMD renamed the package starting with ROCm 7.x; provides the same 'onnxruntime' Python namespace
RUN pip install --no-cache-dir \
  "https://repo.radeon.com/rocm/manylinux/rocm-rel-7.2.2/onnxruntime_migraphx-1.23.2-cp312-cp312-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl"

# Copy ROCm-tested requirements files
COPY docker/requirements_rocm.txt /workspace/

# Install Python dependencies using ROCm-compatible requirements.
# Note: torchaudio (2.10.0+rocm7.2.2) ships pre-built in the base image — pip
# satisfies the 'torchaudio' requirement from requirements.txt immediately.
RUN pip install --no-cache-dir -r /workspace/requirements_rocm.txt

# Install ComfyUI-Manager
RUN git clone --depth 1 https://github.com/Comfy-Org/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager \
  && pip install --no-cache-dir -r custom_nodes/ComfyUI-Manager/requirements.txt

# Copy startup script, models config, and sample workflow
COPY docker/startup.sh /workspace/startup.sh
COPY docker/download_models.py /workspace/download_models.py
COPY docker/models.yaml /workspace/models.yaml
COPY docker/sample_workflow.json /workspace/ComfyUI/

# Make startup script executable
RUN chmod +x /workspace/startup.sh

# Verify ROCm stack is intact after all installs
RUN python - <<'PY'
import torch, torchvision
print(f"torch={torch.__version__} hip_available={torch.cuda.is_available()}")
print(f"torchvision={torchvision.__version__}")
try:
    import torchaudio
    print(f"torchaudio={torchaudio.__version__}")
except Exception as e:
    print(f"torchaudio=unavailable ({e})")
PY

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
