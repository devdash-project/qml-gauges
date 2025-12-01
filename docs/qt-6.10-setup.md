# Qt 6.10 Setup Guide

This guide documents the installation of Qt 6.10 for development on Ubuntu 24.04 (ARM64/aarch64).

## Why Qt 6.10?

Ubuntu 24.04's apt repository provides Qt 6.4.2, which lacks `Shape.CurveRenderer` - a feature introduced in Qt 6.6 that provides built-in antialiasing for QML Shape elements. Without CurveRenderer, vector graphics (like gauge needles) exhibit visible stair-stepping/aliasing that cannot be adequately resolved with MSAA alone.

## Prerequisites

Install the required XCB cursor platform library before running the installer:

```bash
sudo apt install libxcb-cursor0 libxcb-cursor-dev
```

## Download Qt Online Installer

### ARM64 (aarch64)

```bash
cd /tmp
curl -L -o qt-online-installer-linux-arm64-online.run \
  "https://download.qt.io/official_releases/online_installers/qt-online-installer-linux-arm64-online.run"
chmod +x qt-online-installer-linux-arm64-online.run
```

### x86-64

```bash
cd /tmp
curl -L -o qt-online-installer-linux-x64-online.run \
  "https://download.qt.io/official_releases/online_installers/qt-online-installer-linux-x64-online.run"
chmod +x qt-online-installer-linux-x64-online.run
```

## Run the Installer

```bash
# ARM64
/tmp/qt-online-installer-linux-arm64-online.run

# x86-64
/tmp/qt-online-installer-linux-x64-online.run
```

## Installation Steps

1. **Create/Login to Qt Account** - Required for open source downloads
2. **Select "Custom installation"**
3. **Expand Qt → Qt 6.10.x** (or latest available)
4. **Check the following components:**
   - Desktop gcc 64-bit (or gcc_arm64)
   - Qt Quick (included by default)
   - Qt Shader Tools (needed for Shape rendering)
5. **Complete installation** - Installs to `~/Qt/6.10.x/` by default (~2-3 GB)

## Building the Project with Qt 6.10

After installation, configure CMake to use the new Qt installation:

```bash
# ARM64
cmake -B build -DCMAKE_PREFIX_PATH=~/Qt/6.10.0/gcc_arm64

# x86-64
cmake -B build -DCMAKE_PREFIX_PATH=~/Qt/6.10.0/gcc_64

# Build
cmake --build build
```

## Runtime Detection (Backward Compatibility)

The qml-gauges library uses runtime detection to support both old and new Qt versions:

```qml
Shape {
    // Uses CurveRenderer on Qt 6.6+, falls back to GeometryRenderer on older versions
    preferredRendererType: typeof Shape.CurveRenderer !== 'undefined'
        ? Shape.CurveRenderer : Shape.GeometryRenderer
    // ...
}
```

This allows the library to:
- Work on Qt 6.4.x (with basic antialiasing via MSAA)
- Automatically use CurveRenderer on Qt 6.6+ for smooth vector rendering

**Recommendation**: Qt 6.6+ is strongly recommended for quality rendering.

## Verified Installation

Tested on Ubuntu 24.04 (ARM64):
- Qt 6.10.1 installed to `/home/dev/Qt/6.10.1/gcc_arm64`
- CurveRenderer confirmed working with smooth antialiased edges

## References

- [Qt Online Installer Downloads](https://download.qt.io/official_releases/online_installers/)
- [Qt for Linux Documentation](https://doc.qt.io/qt-6/linux.html)
- [Qt Open Source Downloads](https://www.qt.io/download-qt-installer-oss)
