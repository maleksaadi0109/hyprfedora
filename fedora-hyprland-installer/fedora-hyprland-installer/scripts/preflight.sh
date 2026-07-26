#!/usr/bin/env bash
set -Eeuo pipefail

# Preflight Check Script for Fedora Hyprland Installer

echo "=== Fedora Hyprland Preflight Verification ==="

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

log_pass() { echo "[PASS] $1"; PASS_COUNT=$((PASS_COUNT + 1)); }
log_warn() { echo "[WARN] $1"; WARN_COUNT=$((WARN_COUNT + 1)); }
log_fail() { echo "[FAIL] $1"; FAIL_COUNT=$((FAIL_COUNT + 1)); }

# Check 1: Fedora Linux OS
if [ -f /etc/fedora-release ]; then
    FEDORA_VER=$(cat /etc/fedora-release)
    log_pass "Fedora Linux detected ($FEDORA_VER)"
else
    log_fail "Not a Fedora Linux distribution! This skill is Fedora-first."
fi

# Check 2: System Architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "aarch64" ]; then
    log_pass "Supported architecture: $ARCH"
else
    log_warn "Unusual architecture: $ARCH"
fi

# Check 3: Package Manager (dnf)
if command -v dnf &>/dev/null; then
    log_pass "Package manager 'dnf' is available"
else
    log_fail "Package manager 'dnf' not found"
fi

# Check 4: Network Access
if ping -c 1 -W 2 8.8.8.8 &>/dev/null || ping -c 1 -W 2 fedoraproject.org &>/dev/null; then
    log_pass "Network connectivity active"
else
    log_warn "Network connection could not be verified"
fi

# Check 5: Disk Space (require at least 2GB free on /)
FREE_KB=$(df -k / | awk 'NR==2 {print $4}')
if [ "$FREE_KB" -gt 2097152 ]; then
    log_pass "Sufficient disk space available ($((FREE_KB / 1024 / 1024)) GB free)"
else
    log_warn "Low disk space (<2GB free)"
fi

# Check 6: Sudo privilege check
if sudo -n true 2>/dev/null || command -v sudo &>/dev/null; then
    log_pass "Sudo command utility is installed"
else
    log_warn "Sudo command utility not found"
fi

echo "----------------------------------------------"
echo "Preflight Summary: $PASS_COUNT passed, $WARN_COUNT warnings, $FAIL_COUNT failures"

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
