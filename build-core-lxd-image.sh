#!/bin/bash

INSTANCE_NAME=spread-test

# launch the new lxc instance from an ubuntu 20.04 base
lxc launch ubuntu:20.04 $INSTANCE_NAME

# wait a few seconds before proceeding, otherwise we are going to have issues
# with the container (network manager) not being ready yet, and then the rest of
# the commands will fail
sleep 5s

# we build libtpms and swptm from source and preinstall that in the image for TPM emulation support
lxc exec $INSTANCE_NAME -- bash -c "apt update -yqq"
lxc exec $INSTANCE_NAME -- bash -c "apt install snapd ovmf qemu-system-x86 sshpass whois coreutils net-tools iproute2 automake autoconf libtool gcc build-essential libssl-dev dh-exec pkg-config dh-autoreconf libtasn1-6-dev libjson-glib-dev libgnutls28-dev expect gawk socat libseccomp-dev make -yqq"
lxc exec $INSTANCE_NAME -- bash -c "git clone https://github.com/stefanberger/libtpms"
lxc exec $INSTANCE_NAME -- bash -c "git clone https://github.com/stefanberger/swtpm"
lxc exec $INSTANCE_NAME -- bash -c "cd libtpms && ./autogen.sh --with-openssl --prefix=/usr --with-tpm2 && make -j4 && make check && make install"
lxc exec $INSTANCE_NAME -- bash -c "cd swtpm && ./autogen.sh --with-openssl --prefix=/usr && make -j4 && make -j4 check && make install"
lxc exec $INSTANCE_NAME -- bash -c "rm -rf libtpms"
lxc exec $INSTANCE_NAME -- bash -c "rm -rf swtpm"

# stop the container as the last step, the container is now ready for publishing
lxc stop $INSTANCE_NAME

# modify image properties for the published image to make sure that spread
# can match the image
lxc publish $INSTANCE_NAME --alias ucspread
lxc image show ucspread > temp.profile
yq e '.properties.aliases = "ucspread"' -i ./temp.profile
yq e '.properties.remote = "images"' -i ./temp.profile
cat ./temp.profile | lxc image edit ucspread

# cleanup resources
rm ./temp.profile
lxc delete $INSTANCE_NAME
