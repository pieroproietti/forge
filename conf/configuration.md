 echo "=== 1. CREAZIONE BRIDGE E INTERFACCE ==="; 
 cat /etc/network/interfaces.d/sdn 2>/dev/null; 
 echo -e "\n=== 2. CONFIGURAZIONE PROXMOX SDN (La GUI) ==="; grep -A 4 -E 'eggslab|eggsnet' /etc/pve/sdn/*.cfg 2>/dev/null; echo -e "\n=== 3. REGOLE DNSMASQ (DHCP, Hosts, Ethers) ==="; tail -n +1 /etc/dnsmasq.d/eggslab/* 2>/dev/null; echo -e "\n=== 4. ASSEGNAZIONI ATTIVE (Leases) ==="; cat /var/lib/misc/dnsmasq.eggslab.leases 2>/dev/null
=== 1. CREAZIONE BRIDGE E INTERFACCE ===
#version:1

auto eggsnet
iface eggsnet
	address 10.99.0.1/24
	post-up iptables -t nat -A POSTROUTING -s '10.99.0.0/24' -o vmbr0 -j SNAT --to-source 192.168.1.2
	post-down iptables -t nat -D POSTROUTING -s '10.99.0.0/24' -o vmbr0 -j SNAT --to-source 192.168.1.2
	post-up iptables -t raw -I PREROUTING -i fwbr+ -j CT --zone 1
	post-down iptables -t raw -D PREROUTING -i fwbr+ -j CT --zone 1
	bridge_ports none
	bridge_stp off
	bridge_fd 0
	ip-forward on

=== 2. CONFIGURAZIONE PROXMOX SDN (La GUI) ===

=== 3. REGOLE DNSMASQ (DHCP, Hosts, Ethers) ===
==> /etc/dnsmasq.d/eggslab/00-default.conf <==
except-interface=lo
enable-ra
quiet-ra
bind-dynamic
no-hosts
dhcp-leasefile=/var/lib/misc/dnsmasq.eggslab.leases
dhcp-hostsfile=/etc/dnsmasq.d/eggslab/ethers
dhcp-ignore=tag:!known

dhcp-option=26,1500
ra-param=*,mtu:1500,0

# Send an empty WPAD option. This may be REQUIRED to get windows 7 to behave.
dhcp-option=252,"\n"

# Send microsoft-specific option to tell windows to release the DHCP lease
# when it shuts down. Note the "i" flag, to tell dnsmasq to send the
# value as a four-byte integer - that's what microsoft wants.
dhcp-option=vendor:MSFT,2,1i

# If a DHCP client claims that its name is "wpad", ignore that.
# This fixes a security hole. see CERT Vulnerability VU#598349
dhcp-name-match=set:wpad-ignore,wpad
dhcp-ignore-names=tag:wpad-ignore

==> /etc/dnsmasq.d/eggslab/10-eggsnet.conf <==
dhcp-range=set:eggslab-10.99.0.0-24,10.99.0.0,static,255.255.255.0,infinite
dhcp-option=tag:eggslab-10.99.0.0-24,option:router,10.99.0.1
interface=eggsnet


==> /etc/dnsmasq.d/eggslab/20-hosts.conf <==
# /etc/dnsmasq.d/eggslab/20-hosts.conf
dhcp-host=BC:24:11:00:02:01,10.99.0.201,forge-alpine
dhcp-host=BC:24:11:00:02:02,10.99.0.202,forge-arch
dhcp-host=BC:24:11:00:02:03,10.99.0.203,forge-debian
dhcp-host=BC:24:11:00:02:04,10.99.0.204,forge-devuan
dhcp-host=BC:24:11:00:02:05,10.99.0.205,forge-fedora
dhcp-host=BC:24:11:00:02:06,10.99.0.206,forge-manjaro
dhcp-host=BC:24:11:00:02:07,10.99.0.207,forge-opensuse
dhcp-host=BC:24:11:00:02:08,10.99.0.208,forge-ubuntu


==> /etc/dnsmasq.d/eggslab/ethers <==
BC:24:11:DC:31:C7,10.99.0.101

=== 4. ASSEGNAZIONI ATTIVE (Leases) ===
0 bc:24:11:dc:31:c7 10.99.0.101 forge-alpine 01:bc:24:11:dc:31:c7
0 bc:24:11:00:02:02 10.99.0.202 forge-arch ff:ca:53:09:5a:00:02:00:00:ab:11:4e:34:5e:a1:de:b4:06:0f
artisan@father:~$ 

