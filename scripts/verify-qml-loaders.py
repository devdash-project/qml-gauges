#!/usr/bin/env python3
"""
Verify QML Loader source paths and resource paths resolve correctly.

This script checks:
1. All Loader { source: "..." } paths in QML files can be resolved
2. All resource files (.mesh, .ktx, .png, .hdr, etc.) use qrc:/ paths

Catches the silent failure where relative paths work on filesystem
but fail when loaded from Qt resources (qrc://).

Usage:
    python scripts/verify-qml-loaders.py [build_dir]
"""

import os
import re
import sys
from pathlib import Path


def find_loader_sources(qml_file: Path) -> list[tuple[int, str]]:
    """Find all Loader source paths in a QML file."""
    sources = []
    content = qml_file.read_text()

    # Match: source: "path/to/file.qml" (with optional spaces)
    pattern = r'source\s*:\s*["\']([^"\']+\.qml)["\']'

    for i, line in enumerate(content.split('\n'), 1):
        match = re.search(pattern, line)
        if match:
            sources.append((i, match.group(1)))

    return sources


# Resource file extensions that should use qrc:/ paths
RESOURCE_EXTENSIONS = {'.mesh', '.ktx', '.png', '.jpg', '.hdr', '.exr', '.dds', '.obj', '.gltf', '.glb'}


def find_resource_sources(qml_file: Path) -> list[tuple[int, str, str]]:
    """Find all resource source paths that should use qrc:/ prefix.

    Returns list of (line_number, path, extension) tuples for paths that
    don't start with 'qrc:/' and have resource file extensions.
    """
    issues = []
    content = qml_file.read_text()

    # Match: source: "..." where the path doesn't start with qrc:/
    # Captures paths that are not qrc:// prefixed
    pattern = r'source\s*:\s*["\'](?!qrc:/)([^"\']+)["\']'

    for i, line in enumerate(content.split('\n'), 1):
        # Skip comments
        stripped = line.strip()
        if stripped.startswith('//') or stripped.startswith('*'):
            continue

        match = re.search(pattern, line)
        if match:
            path = match.group(1)
            ext = Path(path).suffix.lower()

            # Only flag resource files (not .qml which is handled separately)
            if ext in RESOURCE_EXTENSIONS:
                issues.append((i, path, ext))

    return issues


def resolve_path(qml_file: Path, relative_path: str) -> Path | None:
    """Resolve a relative path from a QML file's directory."""
    base_dir = qml_file.parent
    resolved = (base_dir / relative_path).resolve()

    if resolved.exists():
        return resolved
    return None


def check_qml_module(src_dir: Path, build_dir: Path) -> list[str]:
    """Check all QML files in the module for resolvable Loader sources and resource paths."""
    errors = []

    # Find all QML files
    qml_files = list(src_dir.rglob("*.qml"))

    for qml_file in qml_files:
        # Check for resource files without qrc:/ prefix
        resource_issues = find_resource_sources(qml_file)
        for line_num, path, ext in resource_issues:
            errors.append(
                f"{qml_file.relative_to(src_dir)}:{line_num}: "
                f"Resource file should use qrc:/ prefix: source: \"{path}\"\n"
                f"    -> Use: source: \"qrc:/ModulePath/path/to/file{ext}\""
            )

        # Check Loader sources
        sources = find_loader_sources(qml_file)

        for line_num, source_path in sources:
            # Check if path resolves from source location
            resolved_src = resolve_path(qml_file, source_path)

            # Also check from build output location
            rel_path = qml_file.relative_to(src_dir)
            build_qml = build_dir / "qml" / "DevDash" / "Gauges" / rel_path
            resolved_build = None
            if build_qml.parent.exists():
                resolved_build = resolve_path(build_qml, source_path)

            if not resolved_src and not resolved_build:
                errors.append(
                    f"{qml_file.relative_to(src_dir)}:{line_num}: "
                    f"Cannot resolve Loader source: {source_path}"
                )
            elif resolved_src:
                # Verify the target file is in the same module or properly imported
                # Check if it crosses module boundaries
                src_parts = source_path.split('/')
                if '..' in src_parts:
                    # Relative path going up - potential cross-module issue
                    target_module = None
                    if 'Primitives' in source_path:
                        target_module = 'DevDash.Gauges.Primitives'
                    elif 'Compounds' in source_path:
                        target_module = 'DevDash.Gauges.Compounds'

                    if target_module:
                        errors.append(
                            f"{qml_file.relative_to(src_dir)}:{line_num}: "
                            f"Cross-module Loader source will fail at runtime: {source_path}\n"
                            f"    -> File exists but is in separate QML module ({target_module})\n"
                            f"    -> Fix: Import the module and use component directly, or restructure modules"
                        )

    return errors


def main():
    # Find project root
    script_dir = Path(__file__).parent
    project_root = script_dir.parent

    build_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else project_root / "build"
    src_dir = project_root / "src"

    if not src_dir.exists():
        print(f"ERROR: Source directory not found: {src_dir}", file=sys.stderr)
        sys.exit(1)

    print(f"Checking QML Loader sources in: {src_dir}")
    print(f"Build directory: {build_dir}")
    print()

    errors = check_qml_module(src_dir, build_dir)

    if errors:
        print("=" * 60)
        print("QML LOADER VERIFICATION FAILED")
        print("=" * 60)
        print()
        for error in errors:
            print(f"ERROR: {error}")
            print()
        print(f"Total errors: {len(errors)}")
        print()
        print("These Loader source paths will fail at runtime when loaded from")
        print("Qt resources (qrc:/). The files exist on disk but are in separate")
        print("QML modules with separate resource files.")
        sys.exit(1)
    else:
        print("✓ All QML Loader sources verified successfully")
        sys.exit(0)


if __name__ == "__main__":
    main()
