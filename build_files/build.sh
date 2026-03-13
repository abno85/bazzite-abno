#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# Enable repos
sed -i 's@enabled=0@enabled=1@g' "/etc/yum.repos.d/terra.repo"

# tee /etc/yum.repos.d/netbird.repo <<EOF
# [netbird]
# name=netbird
# baseurl=https://pkgs.netbird.io/yum/
# enabled=1
# gpgcheck=0
# gpgkey=https://pkgs.netbird.io/yum/repodata/repomd.xml.key
# repo_gpgcheck=1
# EOF


# install extra packages from fedora repos
dnf5 install -y \
    codium \
    coolercontrol \
    liquidctl \
    virt-manager

#rpm-ostree install -y \
#    netbird \
#    netbird-ui

# remove pre-installed packages
dnf5 remove -y \
    tailscale \
    waydroid


# Disable repos
# sed -i 's@enabled=1@enabled=0@g' "/etc/yum.repos.d/netbird.repo"
sed -i 's@enabled=1@enabled=0@g' "/etc/yum.repos.d/terra.repo"

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

#systemctl enable podman.socket


# Clean up
dnf5 autoremove -y
dnf5 clean -y all
