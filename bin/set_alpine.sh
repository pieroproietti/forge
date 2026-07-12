# alpine-standard-3.24.0-x86_64.iso
doas sed -i '/community/s/^#//' /etc/apk/repositories
doas apk update
doas apk add alpine-sdk go sudo openssh
doas /sbin/adduser artisan sudo
doas rc-update add sshd default