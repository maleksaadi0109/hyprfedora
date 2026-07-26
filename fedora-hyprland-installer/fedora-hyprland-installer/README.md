# Fedora Hyprland Installer — Antigravity CLI Agent Skill

A Fedora-first **Antigravity CLI Agent Skill** designed to install, configure, verify, repair, update, and uninstall Hyprland safely on Fedora Linux Workstation.

---

## 🌟 Key Features

- **Fedora-First Design**: Native package management using `dnf` and systemd integration.
- **GPU-Aware Engine**: Automatic detection for NVIDIA, AMD Radeon, Intel, and Hybrid graphics with automated Wayland environment flags.
- **Safety Safeguards**: Timestamped user configuration backups (`~/.local/state/fedora-hyprland-installer/backups/`) before any modifications.
- **Non-Destructive**: Never removes pre-existing desktop environments like GNOME or KDE Plasma.
- **Self-Healing Repair**: Dedicated repair mode to fix portal screen-sharing, PipeWire audio, or configuration issues without complete re-installation.
- **Clean Uninstallation**: Cleanly removes installed Hyprland components while preserving your base desktop session choices.

---

## 💻 Supported Systems

- **OS**: Fedora Linux Workstation (Fedora 38, 39, 40, 41, 42, 43+)
- **Architecture**: `x86_64` (aarch64 supported)
- **Session**: Wayland
- **GPUs**: NVIDIA (via RPM Fusion / akmod), AMD Radeon (Mesa), Intel Iris / Arc (Mesa), and Hybrid Laptops.

---

## 📦 What It Installs

The installer deploys a minimal, production-ready Hyprland Wayland environment:
- **Compositor**: `hyprland`
- **Portals**: `xdg-desktop-portal`, `xdg-desktop-portal-hyprland`, `xdg-desktop-portal-gtk`
- **Audio Stack**: `pipewire`, `wireplumber`
- **Utilities**: `kitty` (Terminal), `wofi` (Application Launcher), `waybar` (Status Bar), `dunst` (Notifications), `grim` & `slurp` (Screenshots), `wl-clipboard` (Clipboard manager), `swaybg` (Wallpaper daemon).

---

## 🚀 How to Install & Use with `agy`

### Option 1: Workspace Installation (Local Project)
Place this directory inside your workspace root under `.agents/skills/`:
```text
<workspace-root>/.agents/skills/fedora-hyprland-installer/
```

### Option 2: Global Installation
To make the skill available across all your terminal sessions, copy or symlink it into the global Antigravity skills directory:
```bash
mkdir -p ~/.gemini/antigravity-cli/skills/
cp -r fedora-hyprland-installer ~/.gemini/antigravity-cli/skills/
```

### Usage Examples with `agy`
Launch the Antigravity CLI and type natural prompts:

- **Install Hyprland**:
  > *"Install Hyprland for me on Fedora."*
- **Fix / Repair**:
  > *"Hyprland won't start"* or *"Fix my screen sharing on Hyprland."*
- **Update**:
  > *"Update my Hyprland setup."*
- **Uninstall**:
  > *"Uninstall Hyprland."*

---

## 🛡️ Safety & Backup Policy

Before altering any user configurations in `~/.config/hypr/` or `~/.config/waybar/`, the installer creates a timestamped backup directory:
```text
~/.local/state/fedora-hyprland-installer/backups/YYYYMMDD-HHMMSS/
```
Backups are preserved permanently and never overwritten.

---

## 🛠️ Independent Shell Script Utilities

The included scripts can also be executed directly:

```bash
# Detect system specs and desktop session
./scripts/detect-system.sh

# Detect GPU hardware & active drivers
./scripts/detect-gpu.sh

# Perform preflight sanity checks
./scripts/preflight.sh

# Verify current installation state
./scripts/verify.sh

# Execute non-destructive automated test suite
./tests/test-scripts.sh
```

---

## 📄 License
This project is licensed under the [MIT License](file:///home/supersusi/myprojects/hyperlandfedora/.agents/skills/fedora-hyprland-installer/LICENSE).
