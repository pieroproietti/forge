echo "Impostazione rete statica Debian (192.168.1.$VM_ID_debian)..."
cat <<EOF | sudo tee /etc/network/interfaces
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

allow-hotplug ens18
iface ens18 inet static
    address 192.168.1.$VM_ID_debian
    netmask 255.255.255.0
    gateway 192.168.1.254
    dns-nameservers 8.8.8.8 1.1.1.1
EOF
sudo systemctl restart networking

echo "Installazione strumenti di sviluppo Debian..."
sudo apt-get update
sudo apt-get install -y build-essential golang dpkg-dev