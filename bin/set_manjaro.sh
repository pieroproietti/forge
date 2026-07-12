# manjaro
# ho salvato tutto in 

# archlinux-2026.07.01-x86_64.iso
pacman -Syy --noconfirm openssh
sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl start --now sshd
# Comandi fdisk per partizionamento Legacy (MBR/MSDOS):
fdisk /dev/sda
o           # Crea una nuova tabella delle partizioni DOS/MBR

n           # Crea la partizione primaria Root
p           # Partizione primaria
1           # Numero partizione (1)
            # Settore iniziale predefinito
            # Utilizza tutto lo spazio rimanente

a           # Rendi attiva la partizione (flag boot)

w           # Scrivi le modifiche e esci

# Formattazione e mount della partizione:
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt

echo 'Server = https://mirrors.manjaro.org/repo/stable/$repo/$arch' > /etc/pacman.d/manjaro-mirrorlist

cat << 'EOF' > /tmp/manjaro.conf
[options]
Architecture = auto
SigLevel = Never

[core]
Include = /etc/pacman.d/manjaro-mirrorlist

[extra]
Include = /etc/pacman.d/manjaro-mirrorlist
EOF

finalmente;
pacstrap -C /tmp/manjaro.conf /mnt base manjaro-system manjaro-release linux66 grub networkmanager nano sudo

arch-chroot /mnt

# time
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
hwclock --systohc

