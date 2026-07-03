echo "Impostazione rete statica Arch tramite NetworkManager (192.168.1.$VM_ID_arch)..."
sudo systemctl enable --now NetworkManager

sudo nmcli con delete "ens18" 2>/dev/null || true
sudo nmcli con add type ethernet ifname ens18 con-name ens18 \
  ipv4.method manual \
  ipv4.addresses "$VM_ID_arch/24" \
  ipv4.gateway 192.168.1.254 \
  ipv4.dns "192.168.1.254 8.8.8.8"
  
sudo nmcli con up "ens18"

echo "Installazione strumenti di sviluppo Arch..."
sudo pacman -Sy --noconfirm base-devel go bind-tools
