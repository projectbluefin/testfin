#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Main Build Script
###############################################################################
# This script follows the @ublue-os/bluefin pattern for build scripts.
# It uses set -eoux pipefail for strict error handling and debugging.
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

# Ensure required tools are available
if ! command -v rsync &> /dev/null; then
    echo "Installing rsync for file operations..."
    dnf5 install -y rsync
fi

echo "::group:: Copy Project Bluefin Common Files"

# Copy shared system files from Project Bluefin common layer
# This includes ujust completions, udev rules, and other shared configuration
rsync -rvK /ctx/common/shared/ /

echo "::endgroup::"

echo "::group:: Install Homebrew"

# Extract and install Homebrew from Project Bluefin brew layer
# This provides the Homebrew package manager for runtime package installation
mkdir -p /home/linuxbrew
tar --zstd -xvf /ctx/brew/usr/share/homebrew.tar.zst -C /

# Copy Homebrew system files (ujust commands, etc.)
rsync -rvK /ctx/brew/ / --exclude='usr/share/homebrew.tar.zst'

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
# Example: systemctl mask unwanted-service

echo "::endgroup::"

echo "Custom build complete!"
