# manjaro-base
pacman -S openssh rsync qemu-user-agent
systemctl enable --now sshd
systemctl enable --now qemu-user-agent

# manjaro-forge
pacman -S base-devel git go
