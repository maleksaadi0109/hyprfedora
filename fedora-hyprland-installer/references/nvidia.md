# NVIDIA Support on Fedora Wayland / Hyprland

## Recommended Environment Variables
NVIDIA GPUs require specific Wayland environment flags in `~/.config/hypr/hyprland.conf`:

```text
env = LIBVA_DRIVER_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1
env = NVD_BACKEND,direct
```

## Drivers on Fedora
Always use Fedora/RPM Fusion official packages (`akmod-nvidia`). 
Never use raw `.run` installers from NVIDIA's website as they break Fedora kernel updates.
