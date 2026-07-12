# Fedora-Everything-netinst-x86_64-44-1.7.iso
sudo dnf install -y go @development-tools rpm-build rpmdevtools openssh-server
sudo systemctl enable --now sshd
sudo firewall-cmd --add-service=ssh --permanent
# Sblocca il PermitRootLogin nel file di configurazione
#sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo firewall-cmd --reload
