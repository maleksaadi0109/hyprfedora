# Fedora Hyprland Installer — Antigravity CLI Agent Skill

## Project Goal

Build an Antigravity CLI Agent Skill that can install, configure, verify, repair, update, and uninstall Hyprland on Fedora Linux.

The main goal is:

> A Fedora user should be able to open `agy` and say:
>
> **"Install Hyprland for me."**
>
> The agent should inspect the machine, determine the correct Fedora/GPU setup, perform the installation and configuration, verify the result, and explain what it did.

The user should NOT need to know Fedora package commands, Hyprland configuration, Wayland components, or GPU-specific setup.

This project must be Fedora-first. Do not blindly reuse Arch Linux, Ubuntu, Debian, or NixOS instructions.

---

# 1. Target Platform

Primary target:

- Fedora Workstation
- Fedora KDE is allowed but not the primary target
- Fedora GNOME is allowed and should remain usable
- Wayland systems
- x86_64 first
- NVIDIA, AMD, and Intel GPUs

The project should detect unsupported or unusual systems and stop safely instead of guessing.

---

# 2. Antigravity Skill Structure

Create this structure:

```text
fedora-hyprland-installer/
├── SKILL.md
├── README.md
├── LICENSE
├── scripts/
│   ├── detect-system.sh
│   ├── detect-gpu.sh
│   ├── preflight.sh
│   ├── install.sh
│   ├── configure.sh
│   ├── verify.sh
│   ├── backup.sh
│   ├── repair.sh
│   └── uninstall.sh
├── references/
│   ├── fedora.md
│   ├── hyprland.md
│   ├── nvidia.md
│   ├── amd.md
│   ├── intel.md
│   ├── wayland.md
│   ├── portals.md
│   └── troubleshooting.md
└── tests/
    ├── test-detection.sh
    └── test-scripts.sh
```

The Antigravity skill itself must live in:

```text
<workspace-root>/.agents/skills/fedora-hyprland-installer/
```

For global use, use the currently supported global Antigravity skill directory documented by Google.

---

# 3. SKILL.md Frontmatter

The skill must start with YAML frontmatter similar to:

```yaml
---
name: fedora-hyprland-installer
description: Install, configure, verify, repair, update, and uninstall Hyprland on Fedora Linux. Use this skill when the user asks to install Hyprland on Fedora, configure a Fedora Hyprland desktop, fix a Hyprland installation, configure GPU-specific Hyprland support, configure Wayland portals, monitors, audio, login sessions, or completely remove the Hyprland setup.
---
```

The description must be detailed enough for Antigravity to recognize requests such as:

- install Hyprland
- setup Hyprland
- Fedora Hyprland
- configure Hyprland
- fix Hyprland
- Hyprland doesn't start
- NVIDIA Hyprland
- AMD Hyprland
- Intel Hyprland
- screen sharing doesn't work
- screenshots don't work
- configure monitors
- make Hyprland available at login
- remove Hyprland

---

# 4. Core Agent Behavior

The agent must behave as a system administrator, not as a command generator.

When the user requests installation:

```text
User request
    ↓
Understand intent
    ↓
Inspect system
    ↓
Run preflight
    ↓
Detect Fedora version
    ↓
Detect current desktop/session
    ↓
Detect GPU
    ↓
Detect display manager
    ↓
Detect existing Hyprland installation
    ↓
Detect existing configuration
    ↓
Create backup
    ↓
Plan installation
    ↓
Ask confirmation for privileged/destructive operations
    ↓
Install packages
    ↓
Configure system
    ↓
Configure user environment
    ↓
Verify
    ↓
Report result
```

Never skip system detection.

---

# 5. Safety Rules

This skill modifies a real Linux system.

Follow these rules strictly.

## 5.1 Never blindly execute commands

Before running a command, understand why it is needed.

Never copy a random command from an internet page and execute it without checking what it does.

## 5.2 Use Fedora-native tools

Prefer:

```bash
dnf
```

or the appropriate Fedora package tooling available on the installed Fedora release.

Do not assume:

```bash
apt
pacman
yay
paru
zypper
```

exist.

## 5.3 Never overwrite configuration without backup

Before modifying:

```text
~/.config/hypr/
~/.config/waybar/
~/.config/wofi/
~/.config/rofi/
~/.config/kitty/
~/.config/alacritty/
```

or other user configuration, create a timestamped backup.

Example:

```text
~/.config/hypr.backup-YYYYMMDD-HHMMSS/
```

The exact backup mechanism can be improved by implementation.

## 5.4 Privileged operations

Commands requiring `sudo` must be clearly identified.

Before major system modifications, tell the user what will happen.

Examples:

- installing packages
- enabling/disabling services
- changing display-manager configuration
- modifying GPU drivers
- modifying system configuration
- removing packages

Do not request the user's password.

Let `sudo` ask for it normally.

## 5.5 Never modify bootloader/kernel configuration unless necessary

Do not change:

```text
GRUB
systemd-boot
kernel command line
initramfs
```

unless a specific, verified problem requires it.

If it is required, explain why and ask for confirmation.

## 5.6 Do not remove the existing desktop environment

Installing Hyprland must NOT automatically remove:

- GNOME
- KDE Plasma
- Xfce
- other desktop environments

The user should be able to choose Hyprland from the login screen.

## 5.7 Never assume NVIDIA

GPU detection is mandatory.

Handle:

```text
NVIDIA
AMD
Intel
Unknown
Hybrid laptop
```

separately.

---

# 6. System Detection

Create `scripts/detect-system.sh`.

It should collect information such as:

```text
Fedora release
Kernel
Architecture
Current user
Current desktop environment
Current session type
Display manager
Wayland/X11
GPU
GPU driver
CPU
RAM
Existing Hyprland installation
Existing Hyprland configuration
PipeWire status
WirePlumber status
XDG portal packages
Flatpak availability
```

Useful commands may include:

```bash
cat /etc/fedora-release
uname -r
uname -m
echo "$XDG_CURRENT_DESKTOP"
echo "$XDG_SESSION_TYPE"
loginctl
systemctl --failed
lspci -nnk
dnf list --installed
```

Do not hard-code assumptions.

The script should output machine-readable information where practical.

---

# 7. GPU Detection

Create:

```text
scripts/detect-gpu.sh
```

Detect:

### NVIDIA

Check:

```bash
lspci -nnk
nvidia-smi
```

if available.

Determine whether the NVIDIA driver is already installed and functional.

Do not automatically replace a working driver.

### AMD

Detect AMD GPU and current kernel driver.

### Intel

Detect Intel GPU and current kernel driver.

### Hybrid Graphics

Detect laptops containing combinations such as:

```text
Intel + NVIDIA
AMD + NVIDIA
```

The agent must recognize that hybrid graphics may need special handling.

---

# 8. Preflight

Create:

```text
scripts/preflight.sh
```

The preflight stage should check:

- Fedora
- supported architecture
- network access
- package manager availability
- sudo availability
- disk space
- existing Hyprland
- GPU
- Wayland session
- display manager
- PipeWire
- WirePlumber
- XDG Desktop Portal
- current user configuration
- package repositories

Output:

```text
PASS
WARN
FAIL
```

Example:

```text
[PASS] Fedora detected
[PASS] x86_64 architecture
[PASS] Network available
[PASS] sudo available
[WARN] NVIDIA detected
[PASS] PipeWire running
[WARN] Hyprland already installed
```

---

# 9. Installation Strategy

The installation process must be modular.

Do not place every command in one huge script.

Recommended order:

```text
1. Detect
2. Preflight
3. Backup
4. Package installation
5. GPU-specific setup
6. Wayland components
7. Portal setup
8. Audio setup
9. User configuration
10. Session/login configuration
11. Verification
```

---

# 10. Package Installation

The agent should determine the correct package names for the installed Fedora release rather than assuming package names never change.

Potential components include:

```text
Hyprland
Wayland utilities
XDG Desktop Portal
Hyprland portal backend where applicable
PipeWire
WirePlumber
audio utilities
terminal
application launcher
notification daemon
status bar
wallpaper utility
clipboard utility
screenshot utility
authentication/polkit integration
network management tools
Bluetooth tools
```

Do not install unnecessary packages.

Keep the base installation minimal.

If a component is optional, explain why it is optional.

---

# 11. Hyprland Configuration

Create a clean initial configuration.

The configuration should be usable immediately after installation.

It should include sensible defaults for:

- monitor
- keyboard
- mouse
- terminal
- application launcher
- window management
- workspaces
- basic keybindings
- volume controls
- brightness controls where possible
- screenshots
- logout
- reload configuration
- application closing
- fullscreen
- floating windows

Do not assume a particular monitor resolution.

Use safe defaults and allow the user to customize later.

---

# 12. First-Run Configuration

The generated Hyprland config should be intentionally simple.

Example conceptual bindings:

```text
SUPER + Enter
    open terminal

SUPER + Space
    application launcher

SUPER + Q
    close active window

SUPER + M
    exit session

SUPER + R
    reload configuration

SUPER + 1..9
    switch workspace
```

Do not hard-code an application if it is not installed.

Detect the user's available terminal and launcher first.

---

# 13. Wayland / XDG Desktop Portal

The agent must verify desktop portals.

This is important for:

- screen sharing
- screenshots
- browser integration
- file dialogs
- Flatpak integration

Check:

```bash
systemctl --user
```

and installed portal packages.

If screen sharing is broken, diagnose:

```text
PipeWire
WirePlumber
xdg-desktop-portal
desktop portal backend
Wayland session
```

Do not simply reinstall everything.

---

# 14. Audio

Check:

```text
PipeWire
WirePlumber
PulseAudio compatibility
```

Verify that:

```bash
wpctl status
```

works when available.

Do not replace a functioning audio stack unnecessarily.

---

# 15. Display Manager

Detect the active display manager.

Examples:

```text
GDM
SDDM
LightDM
other
```

Do not replace the display manager simply to install Hyprland.

The desired result is:

```text
Login screen
    ↓
User selects Hyprland
    ↓
Hyprland starts
```

The existing desktop environment should remain available.

---

# 16. NVIDIA

NVIDIA requires special handling.

The agent must:

1. Detect whether NVIDIA is present.
2. Determine whether the driver is working.
3. Determine whether the system is hybrid graphics.
4. Check the current Fedora-supported driver setup.
5. Avoid blindly installing conflicting drivers.
6. Explain any required configuration.
7. Verify rendering after changes.

Never tell the user to install NVIDIA drivers from an arbitrary `.run` installer.

Prefer Fedora-supported packaging and repository mechanisms.

---

# 17. AMD

For AMD:

- detect the GPU
- detect the kernel driver
- verify rendering
- avoid unnecessary proprietary driver installation
- use the Fedora/Mesa stack where appropriate
- verify Hyprland can start

---

# 18. Intel

For Intel:

- detect GPU generation
- detect current kernel driver
- verify rendering
- use Fedora/Mesa stack where appropriate
- verify Hyprland startup

---

# 19. Backup

Create:

```text
scripts/backup.sh
```

Before changing user configuration, create:

```text
~/.local/state/fedora-hyprland-installer/backups/
```

Use timestamped backup directories.

Save at least:

```text
Hyprland config
Waybar config if modified
launcher config if modified
terminal config if modified
relevant user service configuration
installer-generated metadata
```

The backup must not overwrite previous backups.

---

# 20. Verification

Create:

```text
scripts/verify.sh
```

Verification must happen after installation.

Check:

```text
Hyprland binary exists
Hyprland version
Wayland libraries
GPU
GPU rendering
PipeWire
WirePlumber
XDG portal
display manager session
Hyprland config syntax
user configuration
```

If possible, validate Hyprland configuration without starting a new session.

The final report should clearly say:

```text
Installation: SUCCESS / PARTIAL / FAILED
```

and list any warnings.

---

# 21. Repair Mode

Create:

```text
scripts/repair.sh
```

The skill should support:

```text
"Fix my Hyprland"
"Hyprland doesn't start"
"Black screen"
"No audio"
"No screen sharing"
"Monitor doesn't work"
"Keyboard doesn't work"
"Hyprland crashes"
```

Repair workflow:

```text
Detect
↓
Collect logs
↓
Identify likely subsystem
↓
Explain diagnosis
↓
Backup
↓
Apply minimal fix
↓
Verify
```

Do not reinstall the entire system for a small configuration problem.

---

# 22. Logs

When diagnosing problems, inspect relevant logs.

Potential sources:

```bash
journalctl
journalctl --user
systemctl --user --failed
```

Use targeted filtering.

Do not dump enormous logs into the agent context.

Collect only relevant lines.

---

# 23. Uninstall

Create:

```text
scripts/uninstall.sh
```

The user should be able to say:

```text
Uninstall Hyprland
```

The agent must:

1. Explain what will be removed.
2. Backup user configuration.
3. Remove only components installed by this skill when possible.
4. Preserve the user's existing desktop environment.
5. Avoid removing shared system packages that other desktops need.
6. Verify that the remaining desktop environment still works.

Never blindly execute:

```bash
sudo dnf remove '*'
```

or similarly broad commands.

---

# 24. Update

Support:

```text
Update my Hyprland setup
```

The agent should:

1. Detect current setup.
2. Check package updates.
3. Back up configuration.
4. Determine whether configuration changes are needed.
5. Apply only necessary changes.
6. Verify after updating.

Never overwrite a customized user config without preserving it.

---

# 25. User Customization

After a successful installation, the agent can offer:

```text
Would you like me to customize Hyprland?
```

Possible options:

```text
- Minimal
- Developer
- Gaming
- Laptop
- Desktop
- NVIDIA laptop
```

Customization should remain optional.

---

# 26. Developer Profile

A developer profile can optionally install/configure:

```text
Terminal
Git
Neovim
VS Code / compatible editor
tmux
ripgrep
fd
fzf
git-delta
lazygit
```

Do not automatically install development tools during the base Hyprland installation.

---

# 27. Laptop Profile

For laptops, detect:

- battery
- brightness
- touchpad
- lid
- power management

Configure only what is necessary.

Never assume every laptop has the same hardware.

---

# 28. Desktop Profile

For desktop systems, detect:

- number of monitors
- GPU outputs
- refresh rates

Do not automatically force a monitor configuration that could make the display unusable.

---

# 29. Error Handling

Every script must:

- use safe shell practices
- fail clearly
- provide useful error messages
- return meaningful exit codes
- avoid silently ignoring failures

For Bash scripts, prefer:

```bash
set -Eeuo pipefail
```

where compatible with the script's implementation.

Use functions and clear logging.

---

# 30. Idempotency

The installation should be safe to run multiple times.

For example:

```text
First run:
    Install everything.

Second run:
    Detect that it is already installed.
    Repair or update only what is necessary.
```

Do not duplicate configuration entries every time the skill runs.

---

# 31. No Destructive Defaults

Never:

- delete the user's home directory
- remove GNOME/KDE automatically
- replace the display manager unnecessarily
- replace GPU drivers without reason
- overwrite configs without backup
- modify bootloader settings unnecessarily
- add random third-party repositories
- download arbitrary shell scripts and execute them as root

---

# 32. Repository / Source Policy

Use trusted Fedora-supported repositories whenever possible.

If a third-party repository is required:

1. Explain why.
2. Identify the repository.
3. Ask for confirmation.
4. Prefer official/trusted project documentation.
5. Avoid random GitHub scripts.

The agent should verify package sources before installation.

---

# 33. References

Create these files:

## `references/fedora.md`

Document:

- Fedora package management
- Fedora release detection
- Fedora repositories
- systemd
- display managers
- user services
- relevant Fedora conventions

## `references/hyprland.md`

Document:

- Hyprland concepts
- configuration
- Wayland
- sessions
- monitors
- common problems

## `references/nvidia.md`

Document:

- NVIDIA detection
- driver verification
- Wayland considerations
- hybrid graphics

## `references/amd.md`

Document:

- Mesa
- kernel drivers
- AMD rendering verification

## `references/intel.md`

Document:

- Intel graphics
- Mesa
- kernel drivers
- rendering verification

## `references/wayland.md`

Document:

- Wayland session
- compositor
- environment
- common Wayland issues

## `references/portals.md`

Document:

- xdg-desktop-portal
- PipeWire
- screen sharing
- screenshots
- Flatpak integration

## `references/troubleshooting.md`

Document common failure patterns and how to diagnose them.

IMPORTANT:

References should provide knowledge and decision-making guidance. Do not blindly copy commands into scripts without validating them against the current Fedora environment.

---

# 34. Script Requirements

Each script must be executable:

```bash
chmod +x scripts/*.sh
```

Each script must have:

```bash
#!/usr/bin/env bash
```

Scripts should be callable independently where practical.

Examples:

```bash
./scripts/detect-system.sh
./scripts/detect-gpu.sh
./scripts/preflight.sh
./scripts/verify.sh
```

Installation should be orchestrated through the skill rather than relying on one giant script.

---

# 35. Agent Decision Rules

The agent must decide based on evidence.

Example:

```text
IF Fedora detected
AND Hyprland not installed
THEN perform installation.

IF Hyprland already installed
THEN inspect current installation rather than reinstalling.

IF NVIDIA detected
THEN use NVIDIA-specific checks.

IF AMD detected
THEN use AMD-specific checks.

IF Intel detected
THEN use Intel-specific checks.

IF current desktop is GNOME
THEN preserve GNOME.

IF current desktop is KDE
THEN preserve KDE.

IF portal works
THEN do not reinstall portal packages unnecessarily.

IF PipeWire works
THEN do not replace audio configuration.

IF configuration exists
THEN backup before modifying it.
```

---

# 36. User Experience

The agent should communicate clearly.

Bad:

```text
Running commands...
```

Good:

```text
I detected Fedora 43 with an NVIDIA GPU.

Before installing Hyprland I will:
1. Keep your existing GNOME installation.
2. Install the Fedora packages required for Hyprland.
3. Configure the Wayland desktop portal.
4. Create a backup of your existing configuration.
5. Create a minimal Hyprland configuration.
6. Verify the installation.

I need sudo for package installation.
```

Then execute after confirmation when appropriate.

---

# 37. Completion Report

At the end, show something like:

```text
Fedora Hyprland Setup
────────────────────────────

Status: SUCCESS

System:
  Fedora: <version>
  GPU: <GPU>
  Driver: <driver>

Installed:
  Hyprland: <version>
  PipeWire: OK
  WirePlumber: OK
  XDG Portal: OK

Configuration:
  Hyprland config: created
  Backup: <path>

Login:
  Hyprland session: available

Next step:
  Log out and select "Hyprland" from the session selector.
```

If something failed:

```text
Status: PARTIAL

Successful:
  ✓ Hyprland installed
  ✓ PipeWire working
  ✓ Configuration created

Problem:
  ✗ XDG portal backend is not working

Recommended action:
  I can diagnose and repair the portal setup.
```

---

# 38. README

Create a user-facing `README.md`.

It must explain:

- what the project does
- supported Fedora systems
- what it installs
- safety behavior
- how to install the skill
- how to use it with `agy`
- examples
- how to uninstall
- troubleshooting
- contribution guidelines

Example usage:

```text
agy
```

Then:

```text
Install Hyprland on my Fedora system.
```

Other examples:

```text
Fix my Hyprland installation.
```

```text
Configure my monitors for Hyprland.
```

```text
Why is screen sharing not working?
```

```text
Uninstall the Hyprland setup.
```

---

# 39. Testing

Create tests that do not modify the user's real desktop.

At minimum test:

```text
Fedora detection
GPU detection
Missing package detection
Existing Hyprland detection
Backup logic
Idempotency
Verification logic
```

Use mocks or fixture data where necessary.

Do not run destructive installation tests on the developer's real machine.

---

# 40. Important Implementation Principle

This project is NOT:

```text
AI → blindly run shell commands
```

It is:

```text
AI
 ↓
Inspect
 ↓
Understand
 ↓
Plan
 ↓
Backup
 ↓
Ask when necessary
 ↓
Execute
 ↓
Verify
 ↓
Repair if needed
```

The agent must prefer the smallest safe change that achieves the user's goal.

---

# 41. Final Acceptance Criteria

The project is complete only if:

- [ ] Antigravity recognizes the skill.
- [ ] The skill has valid YAML frontmatter.
- [ ] Fedora is detected automatically.
- [ ] GPU is detected automatically.
- [ ] Existing desktop environments are preserved.
- [ ] Existing configuration is backed up.
- [ ] Hyprland can be installed through the agent.
- [ ] Wayland components are checked.
- [ ] XDG portals are checked.
- [ ] PipeWire is checked.
- [ ] NVIDIA receives separate handling.
- [ ] AMD receives separate handling.
- [ ] Intel receives separate handling.
- [ ] Installation is idempotent.
- [ ] Verification is performed.
- [ ] Repair mode exists.
- [ ] Uninstall mode exists.
- [ ] The project avoids destructive defaults.
- [ ] Scripts fail clearly.
- [ ] README explains installation and usage.
- [ ] The project can be placed in `.agents/skills/fedora-hyprland-installer/`.
- [ ] `agy` can discover and use the skill.

---

# 42. Build Instruction for Antigravity

When this document is given to Antigravity, do NOT merely describe the implementation.

Actually create the project files.

Start by:

1. Creating the directory structure.
2. Creating `SKILL.md`.
3. Creating all scripts.
4. Creating all references.
5. Creating `README.md`.
6. Making scripts executable.
7. Running static/syntax checks.
8. Testing detection scripts.
9. Reviewing the project for destructive operations.
10. Reporting exactly what was created.

Do not install Hyprland on the developer's machine merely because you are building this project.

The deliverable is the reusable **Fedora Hyprland Installer Agent Skill**.

