# manjaro-base
# iso ufficiale manjaro
parted -s /dev/sda mklabel msdos
parted -s /dev/sda mkpart primary ext4 1MiB 100%
parted -s /dev/sda set 1 boot on

# monta il disco
mount /dev/sda1 /mnt

# la gettata
basestrap /mnt base linux linux-firmware openssh qemu-guest-agent nano sudo

# in chroot
manjaro-chroot /mnt
passwd
useradd -m -G wheel -s /bin/bash artisan
nqno /etc/sudert
# %wheel ALL=(ALL:ALL) ALL

pacman -S grub
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# manjaro-base
pacman -S openssh rsync qemu-guest-agent
systemctl enable --now sshd
systemctl enable --now qemu-guest-agent

# manjaro-forge
pacman -S base-devel git go
