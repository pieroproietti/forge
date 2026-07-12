# openSUSE (Leap o Tumbleweed - Network Install)

# 1. Installazione ferri del mestiere e demone SSH
sudo zypper install -y go rpm-build rpmdevtools openssh -t pattern devel_basis

# 2. Abilitazione e accensione del motore SSH
sudo systemctl enable --now sshd

# 3. Apertura del varco nel Firewall (identico a Fedora)
sudo firewall-cmd --add-service=ssh --permanent
sudo firewall-cmd --reload

# 4. Sblocco root (Da decommentare all'occorrenza)
#sed -i 's/^.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
#systemctl restart sshd
