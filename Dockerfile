# syntax=docker/dockerfile:1

# Stage 1: Build stage
FROM python:3.11-slim-bookworm AS build

ARG DEBIAN_FRONTEND=noninteractive

# Environment variables
ENV PACKAGES="/usr/local/lib/python3.11/site-packages" \
    PYTHONDONTWRITEBYTECODE="1" \
    PYTHONUNBUFFERED="1" \
    PYTHONFAULTHANDLER="1" \
    PLAYWRIGHT_BROWSERS_PATH="/ms-playwright" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8"

# Copy dependency files first for better cache utilization
COPY requirements.txt pyproject.toml package.json /build/

WORKDIR /build

# Install system dependencies in a single layer with cache mounts
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        fonts-dejavu \
        fonts-droid-fallback \
        fonts-freefont-ttf \
        fonts-liberation \
        fonts-noto \
        fonts-noto-color-emoji \
        fonts-wqy-zenhei \
        git \
        gnupg \
        gobject-introspection \
        libjpeg-dev \
        libcairo2 \
        libcairo2-dev \
        libfreetype6-dev \
        libffi-dev \
        libssl-dev \
        libx11-dev \
        libxext-dev \
        libxrender-dev \
        libpango1.0-dev \
        libharfbuzz-dev \
        libopenjp2-7-dev \
        openssh-client \
        tini \
        xvfb \
        weasyprint \
        zlib1g-dev && \
    # Install Node.js from NodeSource
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    # Install yarn
    npm install -g yarn && \
    # Clean up temp files (apt cache preserved by mount)
    rm -rf /tmp/* /var/tmp/*

# Copy application files
COPY material /build/material
COPY README.md /build/

# Install Python dependencies with cache mount
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip && \
    pip install . && \
    pip install "mkdocs-material[recommended,imaging]"

# Link themes
RUN for theme in mkdocs readthedocs; do \
        rm -rf ${PACKAGES}/mkdocs/themes/$theme; \
        ln -s ${PACKAGES}/material/templates ${PACKAGES}/mkdocs/themes/$theme; \
    done

# Install Playwright and browsers with cache mount
RUN --mount=type=cache,target=/root/.npm \
    mkdir -p /ms-playwright && \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright npm install -g playwright && \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright playwright install --with-deps && \
    chmod -R 755 /ms-playwright

# Set up fonts
RUN mkdir -p /var/cache/fontconfig && \
    chmod 755 /var/cache/fontconfig && \
    fc-cache -f

# Configure git safe directories
RUN git config --system --add safe.directory /docs && \
    git config --system --add safe.directory /site

# Clean up build dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get autoremove -y --purge build-essential libffi-dev && \
    rm -rf /tmp/* /root/.cache

# Stage 2: Runtime stage
FROM python:3.11-slim-bookworm

ARG DEBIAN_FRONTEND=noninteractive

# Environment variables
ENV PACKAGES="/usr/local/lib/python3.11/site-packages" \
    PYTHONDONTWRITEBYTECODE="1" \
    PYTHONUNBUFFERED="1" \
    PYTHONFAULTHANDLER="1" \
    PLAYWRIGHT_BROWSERS_PATH="/ms-playwright" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8"

# Install runtime dependencies only with cache mounts
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        chromium \
        tesseract-ocr \
        tesseract-ocr-eng \
        fonts-dejavu \
        fonts-droid-fallback \
        fonts-freefont-ttf \
        fonts-liberation \
        fonts-noto \
        fonts-noto-color-emoji \
        fonts-wqy-zenhei \
        git \
        libcairo2 \
        libpango1.0-0 \
        libharfbuzz0b \
        libopenjp2-7 \
        openssh-client \
        tini \
        weasyprint \
        xvfb && \
    rm -rf /tmp/* /var/tmp/*

# Create non-root user
RUN groupadd -r -g 1000 mkdocs && \
    useradd -r -u 1000 -g mkdocs -d /home/mkdocs -m mkdocs

# Copy Python packages from build stage
COPY --from=build /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=build /usr/local/bin /usr/local/bin

# Copy Playwright browsers
COPY --from=build /ms-playwright /ms-playwright

# Copy Node.js and npm
COPY --from=build /usr/lib/node_modules /usr/lib/node_modules
COPY --from=build /usr/bin/node /usr/bin/node
COPY --from=build /usr/bin/npm /usr/bin/npm

# Copy tini
COPY --from=build /usr/bin/tini /usr/bin/tini

# Copy git configuration
COPY --from=build /etc/gitconfig /etc/gitconfig

# Copy font cache
COPY --from=build /var/cache/fontconfig /var/cache/fontconfig

# Set up directories with proper permissions
RUN mkdir -p /docs /site && \
    chown -R mkdocs:mkdocs /docs /site /ms-playwright /var/cache/fontconfig && \
    chmod -R 755 /ms-playwright && \
    chmod 777 /var/cache/fontconfig

# Switch to non-root user
USER mkdocs:mkdocs

# Expose MkDocs development server port
EXPOSE 8000

# Start development server by default
WORKDIR /docs
ENTRYPOINT ["/usr/bin/tini", "--", "mkdocs"]
CMD ["serve", "--dev-addr=0.0.0.0:8000"]
