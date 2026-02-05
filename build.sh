#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MATERIAL_REPO="https://github.com/squidfunk/mkdocs-material.git"
IMAGE_NAME="${IMAGE_NAME:-f5xc-mkdocs}"

# Clone mkdocs-material and copy required build files (idempotent)
if [ ! -d "material" ] || [ ! -f "package.json" ] || [ ! -f "pyproject.toml" ]; then
    echo "Cloning mkdocs-material build dependencies..."
    TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"' EXIT
    git clone --depth 1 "$MATERIAL_REPO" "$TEMP_DIR"
    cp -a "$TEMP_DIR/material" ./
    cp -a "$TEMP_DIR/package.json" ./
    cp -a "$TEMP_DIR/pyproject.toml" ./
else
    echo "Build dependencies already present, skipping clone."
fi

echo "Building Docker image: ${IMAGE_NAME}..."
DOCKER_BUILDKIT=1 docker build -t "$IMAGE_NAME" .

echo "Build complete: ${IMAGE_NAME}"
