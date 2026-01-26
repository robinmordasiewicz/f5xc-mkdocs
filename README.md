# MkDocs Material Docker Container

**Production-ready MkDocs Material container with comprehensive plugin ecosystem for documentation generation.**

[![Docker Build](https://github.com/robinmordasiewicz/f5xc-mkdocs/actions/workflows/container.yml/badge.svg)](https://github.com/robinmordasiewicz/f5xc-mkdocs/actions/workflows/container.yml)
[![Material for MkDocs](https://img.shields.io/badge/Material%20for%20MkDocs-9.7.1-526CFE?logo=materialformkdocs&logoColor=white)](https://squidfunk.github.io/mkdocs-material/)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white)](https://www.python.org/)

## Overview

This Docker container provides a complete MkDocs Material environment with 36 curated plugins for documentation generation, PDF export, Git integration, and content enhancement. Built on Python 3.11 with Playwright support for advanced PDF generation and browser automation.

**Container Registry**: `ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest`

## Quick Start

### Pull the Container

```bash
docker pull ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest
```

### Basic Usage

```bash
# Serve documentation locally
docker run -p 8000:8000 -v $(pwd)/docs:/tmp/docs \
  ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest

# Build documentation
docker run -v $(pwd)/docs:/tmp/docs \
  ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest build
```

## GitHub Actions Integration

### Example 1: Build and Deploy Documentation

Use this container in your GitHub Actions workflow to build MkDocs documentation:

```yaml
name: Build Documentation

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-docs:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Build MkDocs documentation
        uses: docker://ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest
        with:
          args: build --strict --site-dir site

      - name: Upload documentation artifact
        uses: actions/upload-artifact@v4
        with:
          name: documentation
          path: site/
```

### Example 2: Build and Deploy to GitHub Pages

Complete workflow for building and deploying to GitHub Pages:

```yaml
name: Deploy Documentation

on:
  push:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for git plugins

      - name: Build documentation
        run: |
          docker run --rm \
            -v ${{ github.workspace }}:/tmp/docs \
            -e GITHUB_REPOSITORY="${{ github.repository }}" \
            -e GITHUB_SHA="${{ github.sha }}" \
            ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest \
            build --strict --site-dir /tmp/docs/site

      - name: Upload Pages artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: site/

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}

    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### Example 3: Multi-Repository Documentation Build

For building documentation that pulls content from multiple repositories:

```yaml
name: Build Multi-Repo Documentation

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout main docs
        uses: actions/checkout@v4
        with:
          path: docs

      - name: Checkout API docs
        uses: actions/checkout@v4
        with:
          repository: your-org/api-docs
          path: docs/api
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Checkout theme
        uses: actions/checkout@v4
        with:
          repository: your-org/docs-theme
          path: theme
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Build documentation
        run: |
          docker run --rm \
            -v ${{ github.workspace }}/docs:/tmp/docs \
            -v ${{ github.workspace }}/theme:/tmp/theme \
            -e INHERIT=/tmp/theme/mkdocs.yml \
            ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest \
            build --config-file /tmp/docs/mkdocs.yml --site-dir /tmp/docs/site

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: documentation
          path: docs/site/
```

### Example 4: PDF Export Workflow

Generate PDF documentation with Playwright:

```yaml
name: Generate PDF Documentation

on:
  release:
    types: [published]

jobs:
  pdf-export:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Build documentation with PDF
        run: |
          docker run --rm \
            -v ${{ github.workspace }}:/tmp/docs \
            -e ENABLE_PDF_EXPORT=1 \
            ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest \
            build --site-dir /tmp/docs/site

      - name: Upload PDF to release
        uses: softprops/action-gh-release@v1
        with:
          files: site/pdf/documentation.pdf
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Local Development

### Serve Documentation with Live Reload

```bash
# Navigate to your documentation directory
cd /path/to/your/docs

# Serve with live reload (port 8000)
docker run -it --rm \
  -p 8000:8000 \
  -v $(pwd):/tmp/docs \
  ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest

# Access at http://localhost:8000
```

### Build Documentation Locally

```bash
# Build to default site/ directory
docker run --rm \
  -v $(pwd):/tmp/docs \
  ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest \
  build

# Build with strict mode (fail on warnings)
docker run --rm \
  -v $(pwd):/tmp/docs \
  ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest \
  build --strict

# Build to custom directory
docker run --rm \
  -v $(pwd):/tmp/docs \
  ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest \
  build --site-dir /tmp/docs/public
```

### Custom Configuration File

```bash
# Use custom mkdocs.yml location
docker run --rm \
  -v $(pwd):/tmp/docs \
  -v $(pwd)/config/mkdocs.yml:/tmp/mkdocs.yml \
  ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest \
  build --config-file /tmp/mkdocs.yml
```

### Interactive Shell for Debugging

```bash
# Open shell inside container
docker run -it --rm \
  -v $(pwd):/tmp/docs \
  --entrypoint /bin/bash \
  ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest

# Inside container, you can run:
# mkdocs --version
# mkdocs build --verbose
# python -m pip list
```

## Configuration

### Volume Mounts

| Path | Purpose | Required |
|------|---------|----------|
| `/tmp/docs` | Documentation source files | Yes |
| `/tmp/site` | Build output directory | No (default) |
| `/tmp/theme` | Custom theme files | No |

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `INHERIT` | Path to parent mkdocs.yml for theme inheritance | - |
| `ENABLE_PDF_EXPORT` | Enable PDF generation with Playwright | `0` |
| `GITHUB_REPOSITORY` | Repository name for git plugins | - |
| `GITHUB_SHA` | Commit SHA for git plugins | - |

### Example with Environment Variables

```bash
docker run --rm \
  -v $(pwd):/tmp/docs \
  -e INHERIT=/tmp/theme/mkdocs.yml \
  -e ENABLE_PDF_EXPORT=1 \
  -e GITHUB_REPOSITORY="your-org/repo" \
  ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest \
  build
```

## Included Plugins

This container includes 36 curated MkDocs plugins:

### Core & Theme
- **mkdocs** (1.6.1) - Core MkDocs
- **mkdocs-material** (9.7.1) - Material Design theme
- **pymdown-extensions** (10.20) - Markdown extensions

### API Documentation
- **mkdocstrings** (1.0.0) - Python & Crystal API documentation

### Dynamic Content
- **mkdocs-macros-plugin** (1.5.0) - Jinja2 templating
- **mkdocs-include-markdown-plugin** (7.2.0) - Include external content

### Git Integration
- **mkdocs-git-authors-plugin** (0.10.0) - Author attribution
- **mkdocs-git-committers-plugin-2** (2.5.0) - Committer tracking
- **mkdocs-git-revision-date-localized-plugin** (1.5.0) - Revision dates

### Navigation
- **mkdocs-awesome-pages-plugin** (2.10.1) - Advanced navigation
- **mkdocs-literate-nav** (0.6.2) - Literate navigation
- **mkdocs-section-index** (0.3.10) - Section index pages

### Media & Visualization
- **mkdocs-glightbox** (0.5.2) - Image lightbox
- **lightgallery** (0.5) - Gallery plugin
- **mkdocs-drawio** (1.13.0) - Draw.io diagrams
- **mkdocs-asciinema-player** (1.1.0) - Terminal recordings

### PDF Export
- **mkdocs-with-pdf** (0.9.3) - PDF generation with Playwright

### Content Enhancement
- **mkdocs-table-reader-plugin** (3.1.0) - External table data
- **mkdocs-exclude** (1.0.2) - Exclude files from build
- **mkdocs-add-teaser** (0.9.1) - Article teasers
- **mkdocs-enumerate-headings-plugin** (0.6.2) - Number headings
- **mkdocs-minify-plugin** (0.8.0) - Minify HTML/CSS/JS

Complete list available in [requirements.txt](requirements.txt).

## Common Use Cases

### Case 1: Simple Documentation Site

**Scenario**: Basic documentation with Material theme

**Project Structure**:
```
your-repo/
├── docs/
│   ├── index.md
│   ├── getting-started.md
│   └── api/
│       └── reference.md
└── mkdocs.yml
```

**mkdocs.yml**:
```yaml
site_name: My Documentation
theme:
  name: material

nav:
  - Home: index.md
  - Getting Started: getting-started.md
  - API Reference: api/reference.md
```

**GitHub Actions Workflow**:
```yaml
- name: Build documentation
  uses: docker://ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest
  with:
    args: build --strict
```

### Case 2: Documentation with API Reference

**Scenario**: Documentation with auto-generated Python API docs

**mkdocs.yml**:
```yaml
site_name: API Documentation
theme:
  name: material

plugins:
  - search
  - mkdocstrings:
      handlers:
        python:
          paths: [src]
          options:
            docstring_style: google
```

**GitHub Actions Workflow**:
```yaml
- name: Build with API docs
  run: |
    docker run --rm \
      -v ${{ github.workspace }}:/tmp/docs \
      ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest \
      build --strict
```

### Case 3: Multi-Language Documentation

**Scenario**: Documentation in multiple languages with theme inheritance

**mkdocs.yml**:
```yaml
INHERIT: theme/mkdocs.yml

site_name: Documentation
extra:
  alternate:
    - name: English
      link: /en/
      lang: en
    - name: Español
      link: /es/
      lang: es
```

**GitHub Actions Workflow**:
```yaml
- name: Build multi-language docs
  run: |
    docker run --rm \
      -v ${{ github.workspace }}:/tmp/docs \
      -v ${{ github.workspace }}/theme:/tmp/theme \
      -e INHERIT=/tmp/theme/mkdocs.yml \
      ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest \
      build
```

## Troubleshooting

### Issue: Build Fails with "Config file not found"

**Solution**: Ensure mkdocs.yml exists in mounted directory
```bash
# Check file exists
ls -la mkdocs.yml

# Mount current directory correctly
docker run -v $(pwd):/tmp/docs ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest build
```

### Issue: Git Plugins Not Working

**Solution**: Ensure full git history is available
```yaml
# In GitHub Actions
- uses: actions/checkout@v4
  with:
    fetch-depth: 0  # Full history
```

### Issue: PDF Generation Fails

**Solution**: Enable Playwright and ensure sufficient memory
```bash
docker run --rm \
  -v $(pwd):/tmp/docs \
  -e ENABLE_PDF_EXPORT=1 \
  --memory="2g" \
  ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest \
  build
```

### Issue: Permission Denied on Output Files

**Solution**: Match user permissions
```bash
docker run --rm \
  -v $(pwd):/tmp/docs \
  --user $(id -u):$(id -g) \
  ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest \
  build
```

### Issue: Custom Fonts Not Loading

**Solution**: Mount fonts directory and update font cache
```bash
docker run --rm \
  -v $(pwd):/tmp/docs \
  -v $(pwd)/fonts:/usr/share/fonts/custom \
  ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest \
  bash -c "fc-cache -f && mkdocs build"
```

## Version Information

### Current Versions
- **MkDocs**: 1.6.1
- **Material for MkDocs**: 9.7.1
- **Python**: 3.11
- **Node.js**: 24.x
- **Total Plugins**: 36 packages (131 with dependencies)

### Update History
- **2026-01-12**: Updated all 27 packages to latest versions
  - mkdocstrings 0.30.0 → 1.0.0 (stable release)
  - mkdocs-table-reader-plugin 2.0.0 → 3.1.0
  - Security fix: CVE-2025-59940 resolved
- **2026-01-10**: Initial optimized release
  - Added missing mkdocs-material package
  - Consolidated plugin ecosystem to 36 packages
  - Fixed dependency conflicts

For complete version details, see [claudedocs/version-update-january-2026.md](claudedocs/version-update-january-2026.md).

## Security

### Container Security
- Based on Python 3.11 official image
- All packages pinned with version constraints
- Security vulnerability scanning enabled
- Regular updates for security patches

### Security Scanning
```bash
# Scan container for vulnerabilities
docker scan ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest

# Check for CVEs
docker scout cves ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest
```

### Security Updates
This container is automatically rebuilt on push to main branch. Security updates are applied promptly:
- **Latest Security Fix**: CVE-2025-59940 (mkdocs-include-markdown-plugin) - RESOLVED

## Contributing

### Reporting Issues
Please report issues at: https://github.com/robinmordasiewicz/f5xc-mkdocs/issues

### Requesting Plugins
To request additional MkDocs plugins:
1. Check if plugin is compatible with Material for MkDocs 9.7.1
2. Verify plugin is actively maintained
3. Open an issue with plugin details and use case

## License

This project follows the licenses of its included components:
- MkDocs: BSD License
- Material for MkDocs: MIT License
- Python: PSF License

## Resources

### Official Documentation
- [MkDocs Documentation](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [MkDocs Plugins](https://github.com/mkdocs/catalog)

### Container Registry
- **GitHub Container Registry**: https://github.com/robinmordasiewicz/f5xc-mkdocs/pkgs/container/f5xc-mkdocs
- **Pull Command**: `docker pull ghcr.io/robinmordasiewicz/f5xc-mkdocs:latest`

### Repository
- **GitHub**: https://github.com/robinmordasiewicz/f5xc-mkdocs
- **Issues**: https://github.com/robinmordasiewicz/f5xc-mkdocs/issues
- **Actions**: https://github.com/robinmordasiewicz/f5xc-mkdocs/actions

---

**Built with ❤️ using Material for MkDocs**
