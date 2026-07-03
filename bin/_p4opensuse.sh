echo "Impostazione rete statica openSUSE (192.168.1.$VM_ID_opensuse)..."
sudo nmcli con add type ethernet ifname ens18 con-name ens18 \
  ipv4.method manual \
  ipv4.addresses "192.168.1.$VM_ID_opensuse/24" \
  ipv4.gateway 192.168.1.254 \
  ipv4.dns "8.8.8.8 1.1.1.1"
sudo nmcli con up "ens18"

echo "Installazione strumenti di sviluppo openSUSE..."
sudo zypper install -y go rpm-build rpmdevtools -t pattern devel_basis
