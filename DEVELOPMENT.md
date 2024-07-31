This file contains some advice for developing Rescatux daily.

Once you have developed Rescatux please check [INSTALL.md](INSTALL.md) file on how to make a proper public release.

# Rescatux Release instructions

Make sure that the commit found at: grub-build-config file is the one you have used to build it (usually it will be the case).
Make Bump commit that summarizes all of the changes from the latest commit.
```
git commit -m 'Bump version to NEWVERSION.'
```

E.g.
```
git commit -m 'Bump version to 2.06s2-beta1.'
```

Then continue with [INSTALL.md - Docker - Release build instructions](INSTALL.md#docker---release-build).

When you make a public announcement make sure to reflect the exact commit or tag you are using to build grub so that grub experts can understand what features to expect from our grub build.

# Docker - Manual development

## Docker - Requirements

Please check [INSTALL.md - Docker - Requirements](INSTALL.md#docker---requirements).

## Debian minimal installation

We first create a Debian 12 minimal installation so that we can install required packages.

```
docker build \
  --build-arg RESCATUX_BUILDER_UID=$(id -u) \
  --build-arg RESCATUX_BUILDER_GID=$(id -g) \
  --tag rescatux-manual-builder . \
  -f manual-builder.Dockerfile
```
## Some developing

Develop whatever you want inside of the docker

```
docker run \
  -it \
  --privileged \
  --env RESCATUX_BUILDER_UID=$(id -u) \
  --env RESCATUX_BUILDER_GID=$(id -g) \
  -v /dev:/dev \
  -v $(pwd):/rescatux-repo:ro \
  -v $(pwd)/live-build-packages:/live-build-packages:ro \
  -v $(pwd)/rescatux-release:/rescatux-build/rescatux-release:rw \
  rescatux-manual-builder:latest
```

## Save your current work
So you need to save your current work so that when you reboot your machine you don't lose your current work inside of the docker image.

- Exit from your docker.

- Identify your docker container id.

```
rescatuxs@adrianpc2020:~$ docker ps -a
CONTAINER ID   IMAGE                             COMMAND                  CREATED          STATUS                      PORTS     NAMES
266d2332828a   rescatux-manual-builder:latest   "bash"                   5 minutes ago    Exited (0) 3 minutes ago              sleepy_pascal
164e04ac8430   rescatux-manual-builder:latest   "-v /home/rescatuxs/…"   6 minutes ago    Created                               loving_snyder
7bc628fc3fb2   6704c2737d6d                      "-v /home/rescatuxs/…"   8 minutes ago    Created                               angry_jang
c027082f37df   6704c2737d6d                      "-v /home/rescatuxs/…"   13 minutes ago   Created                               dreamy_goodall
7bd0f3fc4440   6704c2737d6d                      "bash"                   16 minutes ago   Exited (0) 14 minutes ago             modest_khorana
d28f50a47eff   hello-world                       "/hello"                 36 minutes ago   Exited (0) 36 minutes ago             gifted_sutherland
```

- Commit your recent changes into it:

```
rescatuxs@adrianpc2020:~$ docker commit 266d2332828a rescatux-manual-builder:latest
sha256:bf28c6efaa1595dfde6571a7e257c80c03fa3276fcb698d827f67541e6cbc504
```
## Some more developing

```
docker run \
  -it \
  --privileged \
  --env RESCATUX_BUILDER_UID=$(id -u) \
  --env RESCATUX_BUILDER_GID=$(id -g) \
  -v /dev:/dev \
  -v $(pwd):/rescatux-repo:ro \
  -v $(pwd)/live-build-packages:/live-build-packages:ro \
  -v $(pwd)/rescatux-release:/rescatux-build/rescatux-release:rw \
  rescatux-manual-builder:latest
```

**Do not run** `docker build` again because you will lose your changes.

## How to update Secure Boot Binaries

- Delete associated sha256 files at `secureboot.d/sha256sums/` .
- Delete binaries to be updated at `secureboot-binaries/` (This step is probably optional.)
- Update download scripts at: `secureboot.d/x64/`, `secureboot.d/ia32/` and so on.

## Actual build

```
sudo apt-get remove live-build && sudo apt -qq install -y --allow-downgrades /live-build-packages/*deb
./make-rescatux.sh
```

## Usual git stuff inside Docker image

Use a local-only branch for docker development minimal changes

```
cd /rescatux-build
git pull origin
```

## Tip - How to attach to running container

```
docker exec -it 644ca2ffdfe5 bash
```

This is useful when you want the container to keep building and at the same time you want to keep a look at the logs.

# Additional documentation

## How to test Rescatux image in a SecureBoot Virtual machine

### Requirements

Debian 10 (Also works in Ubuntu 22.04)

```
apt install ovmf qemu-system-x86
```

```
mkdir ~/secureboot-sgd-vm
cd ~/secureboot-sgd-vm
```

We are going to create `start-x64-sgd-usb-secureboot-vm` script.

```
cat > start-x64-sgd-usb-secureboot-vm <<'EOF'
#!/bin/bash

set -Eeuxo pipefail

MACHINE_NAME="test"
QEMU_MAIN_IMG="bigdisk.img"
QEMU_IMG="/home/rescatuxs/gnu/sgd/git/rescatux/rescatux-2.06s2-beta1-multiarch-USB.img"
SSH_PORT="5555"
OVMF_CODE="/usr/share/OVMF/OVMF_CODE_4M.ms.fd"
OVMF_VARS_ORIG="/usr/share/OVMF/OVMF_VARS_4M.ms.fd"
OVMF_VARS="$(basename "${OVMF_VARS_ORIG}")"

if [ ! -e "${QEMU_MAIN_IMG}" ]; then
        qemu-img create -f qcow2 "${QEMU_MAIN_IMG}" 8G
fi

if [ ! -e "${OVMF_VARS}" ]; then
        cp "${OVMF_VARS_ORIG}" "${OVMF_VARS}"
fi

qemu-system-x86_64 \
        -enable-kvm \
        -cpu host -smp cores=4,threads=1 -m 4096 \
        -object rng-random,filename=/dev/urandom,id=rng0 \
        -device virtio-rng-pci,rng=rng0 \
        -name "${MACHINE_NAME}" \
        -drive file="${QEMU_MAIN_IMG}",format=qcow2 \
        -drive file="${QEMU_IMG}",format=raw \
        -net nic,model=virtio -net user,hostfwd=tcp::${SSH_PORT}-:22 \
        -vga virtio \
        -machine q35,smm=on \
        -global driver=cfi.pflash01,property=secure,value=on \
        -drive if=pflash,format=raw,unit=0,file="${OVMF_CODE}",readonly=on \
        -drive if=pflash,format=raw,unit=1,file="${OVMF_VARS}" \
        $@
EOF
```

```
chmod +x start-x64-sgd-usb-secureboot-vm
```

Then you can replace `QEMU_IMG` with the full path to the SecureBoot enabled Rescatux (the non classic one).

### How to test

```
./start-x64-sgd-usb-secureboot-vm -boot menu=on
```

Press `ESC` when Tianocore logo appears.
on boot and then:
- Boot Manager
- UEFI QEMU HARD DISK QM00003

### How to install OSes in your VM

```
./start-x64-sgd-usb-secureboot-vm -boot menu=on -cdrom "ubuntu-22.04.1-live-server-amd64.iso"
```

Press `ESC` when Tianocore logo appears.
on boot and then:
- Boot Manager
- UEFI QEMU DVD-ROM QM00005

### Additional information

[Debian Wiki - SecureBoot/VirtualMachine](https://wiki.debian.org/SecureBoot/VirtualMachine)
