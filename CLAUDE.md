# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the **mkdocs** component of the 40docs platform - a specialized Docker container build system for MkDocs documentation with Material theme. The container is optimized for both development and production use with security hardening and efficient layer caching.

## Container Architecture

### Dockerfile

The repository contains a single optimized `Dockerfile` implementing:

- **Multi-stage build**: Separates build dependencies from runtime for smaller image size
- **Security hardening**: Runs as non-root `mkdocs` user (uid:1000, gid:1000)
- **Layer optimization**: Consolidated RUN commands for efficient caching
- **Proper permissions**: Uses 755 permissions instead of world-writable

### Key Features

- **Material Theme Integration**: Built-in mkdocs-material with theme linking and customization
- **Comprehensive Plugin Ecosystem**: 40+ MkDocs plugins including PDF export, git integration, and content enhancement
- **Playwright Support**: Browser automation for PDF generation and testing
- **Font Support**: Multiple font families including Noto, DejaVu, and Asian language fonts
- **Multi-Architecture**: Supports various deployment scenarios from development to production

## Development Commands

### Container Build Commands

```bash
# Build the container
docker build -t f5xc-mkdocs .

# Build with BuildKit for faster builds
DOCKER_BUILDKIT=1 docker build -t f5xc-mkdocs .
```

### Local Development

```bash
# Run MkDocs development server
docker run -p 8000:8000 -v $(pwd):/docs f5xc-mkdocs

# Run with custom config file
docker run -p 8000:8000 -v $(pwd):/docs -v $(pwd)/mkdocs.yml:/docs/mkdocs.yml f5xc-mkdocs

# Interactive shell for debugging (note: runs as mkdocs user)
docker run -it --entrypoint /bin/bash f5xc-mkdocs

# Verify container runs correctly
docker run --rm f5xc-mkdocs --version
```

## Security Considerations

### Container Security

The Dockerfile implements security best practices:
- **Multi-stage build**: Separates build dependencies from runtime for smaller attack surface
- **Non-root user**: Runs as dedicated `mkdocs` user (uid:1000, gid:1000)
- **Minimal runtime**: Only essential packages in final image
- **Proper permissions**: Uses 755 permissions, not world-writable (777)
- **Layer optimization**: Efficient caching reduces rebuild frequency

### Security Scanning Integration

The build is designed for:
- Container image vulnerability scanning
- Security policy compliance
- Production deployment with minimal attack surface

## Plugin Ecosystem

### Core Plugins Included

The `requirements.txt` includes comprehensive plugin support:

- **Content Enhancement**: mkdocs-macros-plugin, mkdocs-include-markdown-plugin
- **Git Integration**: mkdocs-git-authors-plugin, mkdocs-git-revision-date-localized-plugin
- **PDF Export**: mkdocs-pdf-export-plugin, mkdocs-with-pdf
- **Visual Elements**: mkdocs-glightbox, mkdocs-drawio, lightgallery
- **Navigation**: mkdocs-awesome-pages-plugin, mkdocs-literate-nav
- **Code Documentation**: mkdocstrings[crystal,python]
- **Performance**: mkdocs-minify-plugin

### Plugin Configuration

Plugins are configured through inheritance:
- Default config: `INHERIT: docs/theme/mkdocs.yml`
- Theme linking: Material theme templates linked to mkdocs and readthedocs directories
- Font configuration: Comprehensive font support for international content

## Build Optimization

### Layer Caching Strategy

The Dockerfile is optimized for build caching:
1. **Dependencies First**: Copy requirements.txt, pyproject.toml, and package.json before application code
2. **Consolidated Layers**: System packages and Node.js installed in single RUN command
3. **Selective Multi-Stage Copy**: Only runtime artifacts copied to final image
4. **Application Code Last**: Source files copied after dependencies for optimal rebuild performance

### Multi-Stage Benefits

The build provides:
- **Reduced Image Size**: ~900MB-1.2GB vs ~2.5-3GB for single-stage builds
- **Security Hardening**: Build tools (build-essential, dev packages) excluded from final image
- **Faster Deployment**: Smaller images deploy faster and use less storage
- **Better Caching**: Changes to source code don't invalidate dependency layers

## Integration with 40docs Platform

### GitOps Integration

This container is used within the 40docs GitOps workflow:
- **Theme Inheritance**: Inherits styling from `theme/` repository
- **Content Mounting**: Documentation content mounted from various content repositories
- **Build Pipeline**: Integrated with Kubernetes deployment via Flux

### Cross-Repository Dependencies

The MkDocs container expects:
- Theme configuration from `docs/theme/mkdocs.yml`
- Content directories mounted at `/docs`
- Build output directory at `/site`

## Troubleshooting

### Common Build Issues

```bash
# Font cache issues
fc-cache -f

# Git safe directory issues
git config --global --add safe.directory /docs
git config --global --add safe.directory /site

# Playwright browser installation
PLAYWRIGHT_BROWSERS_PATH=/ms-playwright playwright install chromium
```

### Container Debugging

```bash
# Check container layers
docker history f5xc-mkdocs

# Inspect running container
docker exec -it <container_id> /bin/bash

# Check font availability
docker run --rm f5xc-mkdocs fc-list | grep -i noto

# Verify non-root user
docker run --rm f5xc-mkdocs whoami
# Expected output: mkdocs
```

## Performance Considerations

### Image Size

- **Final Image**: ~900MB-1.2GB with multi-stage optimization
- **Build Stage**: ~2.5GB (not shipped)

### Build Time Optimization

- Use Docker BuildKit for parallel builds: `DOCKER_BUILDKIT=1 docker build .`
- `.dockerignore` excludes unnecessary files from build context
- Layer caching optimized for typical development workflows

## Development Guidelines

### Container Modifications

When modifying the Dockerfile:
- Maintain layer optimization for caching
- Keep build dependencies in build stage only
- Copy only necessary artifacts to runtime stage
- Ensure non-root user has proper permissions
- Test with `docker run --rm f5xc-mkdocs --version`

### Security Updates

Regular maintenance tasks:
- Update base image versions (`python:3.11-slim-bookworm`)
- Pin security-critical dependencies in requirements.txt
- Review and update plugin versions
- Scan containers for vulnerabilities
- Verify non-root execution with `docker run --rm f5xc-mkdocs whoami`