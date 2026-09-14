<<<<<<< HEAD
# codeforge
An open-source IDE for Android. 
=======
# Mobile IDE for Android

An open-source, mobile-first IDE app built with Flutter & Dart, adhering to Material You (Material 3) design principles.

## Features & Core Architecture

### 1. Material You & Edge-to-Edge Design
- Powered by `dynamic_color` for dynamic Material 3 color schemes based on user wallpaper.
- Translucent system bars and edge-to-edge layout.

### 2. Dashboard Panel
- Recent Projects card grid.
- Actions to create new local projects or clone GitHub repositories.

### 3. 3-Panel Workspace UI
- **Panel A (AI Chat Interface)**: Provider selector mapping under-the-hood to OpenCode or Antigravity CLI.
- **Panel B (File Explorer Tree)**: Collapsible project file tree with tap-to-edit file opening.
- **Panel C (Embedded Linux Terminal Viewport)**: Integrated PTY terminal using `xterm` pointing to `/data/data/<package_name>/files/proot_env`.

### 4. Automated CI/CD
- Automated release APK build workflow defined in `.github/workflows/build-apk.yml`.
>>>>>>> feat: Initial commit of Mobile IDE application baseline
