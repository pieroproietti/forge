# fedora-base
dnf install -y openssh-server qemu-guest-agent rsync
systemctl enable --now sshd
firewall-cmd --add-service=ssh --permanent
firewall-cmd --reload

# fedora-forge
dnf install go rpm-build rpmdevtools git make gcc gcc-c++ binutils patch autoconf automake libtool
