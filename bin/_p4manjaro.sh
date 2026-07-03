echo "Impostazione rete statica Manjaro tramite systemd-networkd (192.168.1.$VM_ID_manjaro)..."
sudo rm -f /etc/systemd/network/*.network
sudo mkdir -p /etc/systemd/network/

cat <<EOF | sudo tee /etc/systemd/network/20-ens18.network
[Match]
Name=ens18

[Network]
Address=192.168.1.$VM_ID_manjaro/24
Gateway=192.168.1.254
DNS=192.168.1.254
DNS=8.8.8.8
EOF

sudo systemctl enable --now systemd-networkd
sudo systemctl enable --now systemd-resolved
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-networkd

echo "Installazione strumenti di sviluppo Manjaro..."
sudo pacman -Sy --noconfirm base-devel go
