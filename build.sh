#!/bin/bash
# build.sh - Build ComfyUI ROCm Docker image

set -e

# Configuration
IMAGE_NAME="comfyui-rocm"
VERSION="${1:-latest}"
DETAILED_TAG="comfyui_0.19.3__rocm7.2.2_ubuntu24.04_py3.12_pytorch_2.10.0"

echo "🐳 Building ComfyUI ROCm Docker image..."
echo "📦 Tags: ${IMAGE_NAME}:${VERSION}, ${IMAGE_NAME}:${DETAILED_TAG}"
echo ""

# Build the image with both tags using BuildKit (buildx)
echo "🔨 Building Docker image with BuildKit..."
docker buildx build -f docker/Dockerfile -t "${IMAGE_NAME}:${VERSION}" -t "${IMAGE_NAME}:${DETAILED_TAG}" --progress=plain --load .
