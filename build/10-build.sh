#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Main Build Script
###############################################################################
# This script follows the @projectbluefin/distroless pattern for build scripts.
# It uses set -eoux pipefail for strict error handling and debugging.
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

echo "::group:: Copy Project Bluefin Common and Brew Files"

# Remove ublue-os-just package to avoid conflicts with projectbluefin/common files
# Following the pattern from ublue-os/bluefin
dnf remove -y ublue-os-just

# Copy all system files from Project Bluefin common and brew layers
# This includes ujust completions, udev rules, Homebrew, and other shared configuration
# Following the distroless pattern: https://github.com/projectbluefin/distroless
cp -avf /ctx/system_files/shared/. /
cp -avf /ctx/system_files/brew/. /

echo "::endgroup::"

echo "::group:: Copy Custom Files"

# Copy Brewfiles to standard location
mkdir -p /usr/share/ublue-os/homebrew/
cp /ctx/custom/brew/*.Brewfile /usr/share/ublue-os/homebrew/

# Consolidate Just Files
mkdir -p /usr/share/ublue-os/just/
find /ctx/custom/ujust -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >> /usr/share/ublue-os/just/60-custom.just

# Copy Flatpak preinstall files
mkdir -p /etc/flatpak/preinstall.d/
cp /ctx/custom/flatpaks/*.preinstall /etc/flatpak/preinstall.d/

echo "::endgroup::"

echo "::group:: Install Packages"

# Install packages using dnf5
# Example: dnf5 install -y tmux

# Example using COPR with isolated pattern:
# copr_install_isolated "ublue-os/staging" package-name

echo "::endgroup::"

echo "::group:: System Configuration"

# Enable/disable systemd services
systemctl enable podman.socket

# Enable brew services (from Project Bluefin brew layer)
systemctl enable brew-setup.service
systemctl enable brew-upgrade.timer
systemctl enable brew-update.timer

# Example: systemctl mask unwanted-service

echo "::endgroup::"

echo "Custom build complete!"
