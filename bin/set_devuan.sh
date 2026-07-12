# debian-13.4.0-amd64-netinst.iso
sudo apt-get update
sudo apt-get install -y build-essential golang dpkg-dev openssh-server
update-rc.d ssh defaults
update-rc.d ssh enable
service ssh start