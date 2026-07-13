# opensource-base
zypper install openssh rsync
systemctl enable --now sshd
firewall-cmd --add-service=ssh --permanent
firewall-cmd --reload

# opensource-forge
zypper install -y go rpm-build rpmdevtools git
zypper install -y -t pattern devel_basis
