#!/usr/bin/env bash
set -Eeuo pipefail

# Uninstall Script for Fedora Hyprland Installer

echo "=== Uninstall Hyprland Setup ==="

PACKAGES_TO_REMOVE=(
    "hyprland"
    "xdg-desktop-portal-hyprland"
)

echo "The following Hyprland-specific packages will be removed:"
for pkg in "${PACKAGES_TO_REMOVE[@]}"; do
    echo "  - $pkg"
done

echo ""
echo "Note: Base desktop environments (GNOME, KDE Plasma, Xfce) and user backup files will NOT be touched."

# Run backup prior to uninstallation
SCRIPT_DIR="$(dirname "$0")"
if [ -f "${SCRIPT_DIR}/backup.sh" ]; then
    echo "[+] Creating final backup before uninstallation..."
    "${SCRIPT_DIR}/backup.sh" || true
fi

if command -v dnf &>/dev/null; then
    echo "[+] Executing dnf removal..."
    sudo dnf remove -y "${PACKAGES_TO_REMOVE[@]}"
    echo "[✓] Hyprland packages removed successfully."
else
    echo "[!] dnf package manager not found."
    exit 1
fi

echo "Uninstallation finished cleanly."
