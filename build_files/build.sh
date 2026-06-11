#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# Enable repos
sed -i 's@enabled=0@enabled=1@g' "/etc/yum.repos.d/terra.repo"
dnf5 -y copr enable lizardbyte/beta

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
dnf5 -y --setopt=install_weak_deps=False install \
    codium \
    coolercontrol \
    edk2-ovmf \
    guestfs-tools \
    headsetcontrol \
    kde-partitionmanager \
    libvirt \
    liquidctl \
    podman-machine \
    podman-tui \
    qemu-kvm \
    rclone \
    restic \
    Sunshine \
    virt-manager \
    waypipe \
    yakuake

# Install Docker
docker_pkgs=(
    containerd.io
    docker-buildx-plugin
    docker-ce
    docker-ce-cli
    docker-compose-plugin
)
dnf5 config-manager addrepo --from-repofile="https://download.docker.com/linux/fedora/docker-ce.repo"
dnf5 config-manager setopt docker-ce-stable.enabled=0
dnf5 -y install --enable-repo="docker-ce-stable" "${docker_pkgs[@]}" || {
    # Use test packages if docker pkgs is not available for f42
    if (($(lsb_release -sr) == 42)); then
        echo "::info::Missing docker packages in f42, falling back to test repos..."
        dnf5 install -y --enablerepo="docker-ce-test" "${docker_pkgs[@]}"
    fi
}

# Load iptable_nat module for docker-in-docker.
# See:
#   - https://github.com/ublue-os/bluefin/issues/2365
#   - https://github.com/devcontainers/features/issues/1235
mkdir -p /etc/modules-load.d && cat >>/etc/modules-load.d/ip_tables.conf <<EOF
iptable_nat
EOF

#rpm-ostree install -y \
#    netbird \
#    netbird-ui

# remove pre-installed packages
dnf5 -y remove \
    code \
    kio-gdrive \
    mesa-libOpenCL \
    makemkv \
    tailscale \
    waydroid


# Disable repos
# sed -i 's@enabled=1@enabled=0@g' "/etc/yum.repos.d/netbird.repo"
sed -i 's@enabled=1@enabled=0@g' "/etc/yum.repos.d/terra.repo"
dnf5 -y copr disable lizardbyte/beta

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable docker.socket
#systemctl enable podman.socket
#systemctl enable bazzite-dx-groups.service
#systemctl enable ublue-system-setup.service

# Clean up
dnf5 -y autoremove
dnf5 -y clean all
