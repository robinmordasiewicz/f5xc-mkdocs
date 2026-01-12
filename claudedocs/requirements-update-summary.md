# Requirements Update Summary

**Date**: January 10, 2026
**Action**: Updated requirements.txt with critical fixes

## Files Created

1. **`requirements.txt`** (RECOMMENDED) - Optimized version
   - Adds mkdocs-material>=9.7.0,<10.0.0
   - Removes deprecated mkdocs-material-extensions
   - Adds version pins to all packages
   - Removes redundant plugins
   - Consolidates to 1 PDF export plugin
   - 30 packages (down from 45)

2. **`requirements-conservative.txt`** - Minimal changes version
   - Adds mkdocs-material>=9.7.0,<10.0.0
   - Removes deprecated mkdocs-material-extensions
   - Adds version pins to all packages
   - Keeps all other original plugins
   - 43 packages (minimal reduction)

3. **`requirements.txt.backup`** - Original file backup
   - Your original requirements.txt (no version pins)
   - Keep for reference

## Critical Changes (Both Versions)

### ✅ Added
- **mkdocs-material>=9.7.0,<10.0.0** (THE CRITICAL MISSING PACKAGE)
- Version pins for all packages (reproducible builds)

### ❌ Removed
- **mkdocs-material-extensions** (deprecated - functionality now built into Material)

## Additional Changes (Optimized Version Only)

### Removed Redundant Plugins
Material for MkDocs 9.7.0 has native support for these:
- mkdocs-content-tabs → Use Material's native tabs
- mkdocs-badges → Use Material's native admonitions/icons
- mkdocs-github-admonitions-plugin → Use Material's native admonitions

### Consolidated Export Plugins
Original had 3 different PDF export plugins:
- Kept: mkdocs-with-pdf (most feature-rich)
- Removed: mkdocs-pdf-export-plugin
- Removed: mkdocs-exporter

### Removed Experimental/Unclear
- docs-chat-bot (maintenance status unclear)
- markitdown (unclear purpose in MkDocs context)
- mkdocs-monorepo-plugin (related to deprecated projects plugin)

## Which Version Should You Use?

### Use `requirements.txt` (Optimized) if:
- ✅ You want best practices for 2026
- ✅ You want to remove redundancies
- ✅ You want a cleaner, more maintainable setup
- ✅ You're okay testing to ensure removed plugins weren't used

### Use `requirements-conservative.txt` if:
- ⚠️ You want minimal disruption
- ⚠️ You're unsure which plugins are actively used
- ⚠️ You want to evaluate plugins gradually
- ⚠️ You'll manually remove plugins later

## Testing the Update

### Basic Test (Dry Run)
```bash
# Test installation without actually installing
pip install --dry-run -r requirements.txt
```

### Full Test (Recommended)
```bash
# 1. Create a virtual environment for testing
python3 -m venv test-env
source test-env/bin/activate

# 2. Install the new requirements
pip install -r requirements.txt

# 3. Test MkDocs build (if you have mkdocs.yml configured)
mkdocs build --strict

# 4. Check for import errors
python -c "import mkdocs_material; print(mkdocs_material.__version__)"

# 5. Deactivate when done
deactivate
```

### Generate Lockfile
```bash
# After confirming installation works
pip freeze > requirements.lock
```

## Next Steps

1. **Choose your version**:
   - Copy `requirements.txt` (already default) OR
   - Copy `requirements-conservative.txt` to `requirements.txt`

2. **Test the installation**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Update mkdocs.yml** to enable Material built-in plugins:
   ```yaml
   plugins:
     - search      # Built-in full-text search
     - tags        # Content categorization
     # Optional - enable as needed:
     # - blog      # Blogging support
     # - social    # Social card generation
     # - optimize  # Media optimization
     # - privacy   # GDPR compliance
     # - offline   # Offline documentation
     # - meta      # Metadata management
   ```

4. **Test your documentation build**:
   ```bash
   mkdocs build --strict
   mkdocs serve  # Test locally
   ```

5. **Generate lockfile**:
   ```bash
   pip freeze > requirements.lock
   ```

6. **Commit changes**:
   ```bash
   git add requirements.txt requirements.lock
   git commit -m "Update requirements: add Material 9.7.0, remove deprecated plugins"
   ```

## Rollback If Needed

If you encounter issues:

```bash
# Restore original requirements
cp requirements.txt.backup requirements.txt

# Or use conservative version
cp requirements-conservative.txt requirements.txt

# Reinstall
pip install -r requirements.txt
```

## Material for MkDocs Built-in Plugins

These are now included with Material 9.7.0 (no separate installation):

- **search** - Full-text search with lunr.js
- **blog** - First-class blogging support
- **tags** - Content categorization and tagging
- **social** - Automatic social card generation
- **optimize** - Media file optimization
- **privacy** - GDPR compliance, self-hosting external assets
- **offline** - Offline-capable documentation
- **meta** - Metadata management for folders
- **group** - Plugin grouping and conditional enabling
- **info** - Bug reporting helper

Enable them in `mkdocs.yml` under the `plugins:` section.

## Additional Resources

- Full analysis: `claudedocs/plugin-analysis-2026.md`
- Material for MkDocs docs: https://squidfunk.github.io/mkdocs-material/
- Plugin catalog: https://github.com/mkdocs/catalog
- Zensical (future): https://zensical.org/

## Version Comparison

| Metric | Original | Conservative | Optimized |
|--------|----------|--------------|-----------|
| Total packages | 45 | 43 | 30 |
| Version pins | 0 | 43 | 30 |
| mkdocs-material | ❌ Missing | ✅ Added | ✅ Added |
| Deprecated packages | 1 | 0 | 0 |
| Redundant plugins | Several | Several | Removed |
| PDF export plugins | 3 | 3 | 1 |

## Support & Questions

- See `claudedocs/plugin-analysis-2026.md` for detailed analysis
- Material for MkDocs is in maintenance mode (12-month security support)
- Zensical is the next-generation replacement (monitor development)
- Material 9.7.0 includes ALL previously premium features for free
