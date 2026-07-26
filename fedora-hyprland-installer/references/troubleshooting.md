# Hyprland Troubleshooting Matrix

## Symptom 1: Black Screen on Boot (NVIDIA)
- **Cause**: Missing Wayland environment variables or modeset issue.
- **Fix**: Check `nvidia_drm.modeset=1` kernel parameter and add `WLR_NO_HARDWARE_CURSORS=1` in `hyprland.conf`.

## Symptom 2: Screen Sharing Not Working (OBS / Browser)
- **Cause**: Inactive portal or pipewire environment variable missing.
- **Fix**: Run:
  ```bash
  systemctl --user restart xdg-desktop-portal
  systemctl --user restart xdg-desktop-portal-hyprland
  ```

## Symptom 3: No Sound Output
- **Cause**: PipeWire or WirePlumber service failed.
- **Fix**: Run:
  ```bash
  systemctl --user restart pipewire wireplumber
  ```
