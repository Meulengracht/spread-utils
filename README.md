# Spread utility scripts

This repository contains utility scripts for testing Ubuntu Core with spread

## Prerequisites

You need the following two snaps installed, one is for the LXD container that you need
to run spread tests, and the other is a utility snap for building the images automatically.
```
sudo snap install lxd --channel=latest/stable
sudo snap install yq --channel=latest/stable
```

## build-core-lxd-image.sh

This scripts prepares a lxd image containing neccessary packages for testing 
the core-initrd, core20 and core22 repositories with spread. The script creates
a new container, builds neccessary packages from source, installs additional packages
and then publishes the container image with additional properties required for testing.
