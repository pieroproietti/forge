echo "Impostazione rete statica Ubuntu (192.168.1.$VM_ID_ubuntu) via Netplan..."

sudo rm -f /etc/netplan/*.yaml

cat <<EOF | sudo tee /etc/netplan/01-static-ip.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens18:
      dhcp4: no
      addresses:
        - 192.168.1.$VM_ID_ubuntu/24
      routes:
        - to: default
          via: 192.168.1.254
      nameservers:
        addresses:
          - 192.168.1.254
          - 8.8.8.8
          - 8.8.4.4
EOF

sudo chmod 600 /etc/netplan/01-static-ip.yaml
sudo netplan apply

echo "Installazione strumenti di sviluppo Ubuntu..."
sudo apt-get update
sudo apt-get install -y build-essential golang dpkg-dev
