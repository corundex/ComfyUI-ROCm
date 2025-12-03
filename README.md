# ComfyUI ROCm Docker Image

🔥 **ComfyUI with AMD ROCm support** - Run ComfyUI on AMD GPUs with optimized ROCm-compatible dependencies.

[![Docker Pulls](https://img.shields.io/docker/pulls/corundex/comfyui-rocm)](https://hub.docker.com/r/corundex/comfyui-rocm) [![ROCm](https://img.shields.io/badge/ROCm-6.4+-green)](https://rocm.docs.amd.com/) [![AMD GPU](https://img.shields.io/badge/AMD-RX%206000%2B-red)](https://www.amd.com/en/products/graphics/desktops/radeon.html)

![ComfyUI Interface](Screenshot.png)
*ComfyUI running on AMD ROCm with sample workflow and generated landscape image*

## 📋 Version Information

**Base Image**: `rocm/pytorch:rocm7.1.1_ubuntu24.04_py3.12_pytorch_release_2.9.1`
**Python**: 3.12.x
**PyTorch**: 2.9.1
**ROCm**: 7.1.1
**ComfyUI**: v0.3.76 (30c259c, 2025-12-02)

## ✨ Key Features

- 🎨 **Node-based AI workflow** - Visual interface for creating complex AI pipelines
- 🔥 **AMD ROCm optimized** - Native AMD GPU acceleration with ROCm 6.4+
- 📦 **Smart model management** - Automatic downloads with configurable model sets
- 🧪 **Tested compatibility** - All dependencies verified on real AMD hardware
- 🎯 **Ready to use** - Pre-configured with sample workflows
- 💾 **Persistent storage** - Models and outputs preserved across restarts

## 🚀 Quick Start

```bash
# Pull and run ComfyUI with ROCm support
docker run -d \
  --device=/dev/kfd \
  --device=/dev/dri \
  --group-add=video \
  -p 8188:8188 \
  -v $(pwd)/models:/workspace/ComfyUI/models \
  -v $(pwd)/output:/workspace/ComfyUI/output \
  corundex/comfyui-rocm:latest
```

Access ComfyUI at: [http://localhost:8188](http://localhost:8188)

## 📋 Requirements

| Component  | Requirement                                |
| ---------- | ------------------------------------------ |
| **GPU**    | AMD RX 6000/7000+ series with ROCm support |
| **VRAM**   | 8GB minimum (16GB+ recommended)            |
| **OS**     | Linux (Ubuntu 24.04+ recommended)          |
| **Docker** | Latest version with GPU support            |
| **ROCm**   | Drivers 6.4+ installed on host             |

## 🔧 Setup Instructions

### 1. Install ROCm Drivers

```bash
# Ubuntu/Debian
curl -fsSL https://repo.radeon.com/rocm/rocm.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/rocm.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.4 jammy main" | sudo tee /etc/apt/sources.list.d/rocm.list
sudo apt update && sudo apt install rocm-dkms
sudo usermod -a -G render,video $USER
```

### 2. Verify ROCm Installation

```bash
rocm-smi  # Should show your AMD GPU(s)
```

### 3. Run ComfyUI

```bash
docker run -d \
  --name comfyui-rocm \
  --device=/dev/kfd --device=/dev/dri --group-add=video \
  -p 8188:8188 \
  -v ./models:/workspace/ComfyUI/models \
  -v ./output:/workspace/ComfyUI/output \
  corundex/comfyui-rocm:latest
```

## 🎛️ Model Management

Control model downloading with the `MODEL_DOWNLOAD` environment variable:

| Mode             | Description                   | Models Included                                       |
| ---------------- | ----------------------------- | ----------------------------------------------------- |
| `default`        | Essential starter (4GB)       | SD 1.5                                                |
| `common`         | Comprehensive set (~30GB)     | SD 1.5, SDXL, ControlNets, upscalers, VAE, embeddings |
| `realistic`      | Photo-realistic models (~8GB) | Realistic Vision, DreamShaper, VAE                    |
| `photorealistic` | SDXL realistic (~12GB)        | Juggernaut XL, RealVisXL                              |
| `artistic`       | Creative/stylized (~2GB)      | Deliberate v2                                         |
| `all`            | Everything (~100GB)           | All model sets combined                               |
| `none`           | Skip downloads                | Use existing models only                              |

### Usage Examples

```bash
# Default models (SD 1.5)
docker run -d --device=/dev/kfd --device=/dev/dri --group-add=video \
  -p 8188:8188 -v ./models:/workspace/ComfyUI/models \
  corundex/comfyui-rocm:latest

# All models (~100GB download)
docker run -d --device=/dev/kfd --device=/dev/dri --group-add=video \
  -p 8188:8188 -e MODEL_DOWNLOAD=all \
  -v ./models:/workspace/ComfyUI/models \
  corundex/comfyui-rocm:latest

# Use existing models only
docker run -d --device=/dev/kfd --device=/dev/dri --group-add=video \
  -p 8188:8188 -e MODEL_DOWNLOAD=none \
  -v ./models:/workspace/ComfyUI/models \
  corundex/comfyui-rocm:latest
```

## 🐳 Docker Compose

```yaml
services:
  comfyui-rocm:
    image: corundex/comfyui-rocm:latest
    container_name: comfyui-rocm
    devices:
      - /dev/kfd:/dev/kfd
      - /dev/dri:/dev/dri
    group_add:
      - video
    ports:
      - "8188:8188"
    volumes:
      - ./data/models:/workspace/ComfyUI/models
      - ./data/output:/workspace/ComfyUI/output
      - ./data/input:/workspace/ComfyUI/input
      - ./data/custom_nodes:/workspace/ComfyUI/custom_nodes
      - ./data/user:/workspace/ComfyUI/user
    environment:
      - MODEL_DOWNLOAD=default
      - HIP_VISIBLE_DEVICES=0
      - CUDA_VISIBLE_DEVICES=""
    restart: unless-stopped
```

Run with: `docker compose up -d`

## ⚡ Performance & Hardware

### Tested Hardware

- **AMD Radeon RX 9060 XT** (16GB VRAM) ✅

### Performance Metrics

- **Generation Time**: ~30-60s for 512x512 images
- **VRAM Usage**: 4-8GB for basic operations  
- **Model Loading**: ~30-60s first time, cached afterward
- **Batch Processing**: Multiple images supported

### Tips

- Mount persistent volumes to avoid re-downloading models
- Start with `default` models, upgrade to larger sets as needed
- Use fast SSD storage for optimal performance

## 🔍 Troubleshooting

| Issue                     | Solution                                                                                                           |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| **Container won't start** | Check ROCm drivers: `rocm-smi`                                                                                     |
| **No GPU detected**       | Verify container GPU access: `docker exec comfyui-rocm python -c "import torch; print(torch.cuda.is_available())"` |
| **Model download fails**  | Check internet connection, disk space, and logs                                                                    |
| **Out of memory**         | Reduce batch size, use smaller models, ensure 8GB+ VRAM                                                            |
| **Models not found**      | Verify downloads completed and file permissions                                                                    |

## 📄 License & Credits

This project is licensed under GPL-3.0. See the [LICENSE](LICENSE) file for details.

### Third-Party Components

- **ComfyUI**: GPL-3.0 - [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
- **PyTorch**: BSD 3-Clause - [PyTorch](https://pytorch.org/)
- **ROCm**: Various OSS licenses - [AMD ROCm](https://rocm.docs.amd.com/)

**Acknowledgments:**

- [ComfyUI](https://github.com/comfyanonymous/ComfyUI) - Node-based AI workflow interface

- [AMD ROCm](https://rocm.docs.amd.com/) - Open source GPU computing platform  
- ROCm community for AMD GPU AI support

---

🔗 **Links:** [Docker Hub](https://hub.docker.com/r/corundex/comfyui-rocm) | [GitHub](https://github.com/corundex/comfyui-rocm) | [ComfyUI](https://github.com/comfyanonymous/ComfyUI)
