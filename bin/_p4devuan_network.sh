# Nota: Su Devuan usiamo sysvinit o runit, systemctl potrebbe non funzionare. 
# Modifichiamo il riavvio della rete.
echo "Impostazione rete statica Devuan (192.168.1.$VM_ID_devuan)..."
cat <<EOF | sudo tee /etc/network/interfaces
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

allow-hotplug ens18
iface ens18 inet static
    address 192.168.1.$VM_ID_devuan
    netmask 255.255.255.0
    gateway 192.168.1.254
    dns-nameservers 8.8.8.8 1.1.1.1
EOF
# Devuan non usa systemd. Usiamo init.d.
sudo /etc/init.d/networking restart
