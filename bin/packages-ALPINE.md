# alpine-base
sudo apk add rsync qemu-guest-agent

# alpine-forge
sudo apk update
sudo apk add alpine-sdk go rsync

# firma (importante)
abuild-keygen -a -i