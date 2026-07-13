# arch-base
sudo pacman -S openssh rsync qemu-guest-agent
sudo systemctl enable --now sshd
sudo systemctl enable --now qemu-guest-agent
# arch-forge
sudo pacman -S base-devel git go
