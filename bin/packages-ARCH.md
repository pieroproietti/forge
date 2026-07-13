# arch-base
pacman -S openssh rsync qemu-user-agent
systemctl enable --now sshd
systemctl enable --now qemu-user-agent
# arch-forge
pacman -S base-devel git go


