echo "Impostazione rete statica Alpine (192.168.1.$VM_ID_alpine)..."
cat <<EOF | sudo tee /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.168.1.$VM_ID_alpine
    netmask 255.255.255.0
    gateway 192.168.1.254
EOF
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" | sudo tee /etc/resolv.conf
sudo /etc/init.d/networking restart
