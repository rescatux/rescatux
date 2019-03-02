This README explains how a buster i386 chroot can be setup.
This might not appropiate in most of your systems.
Be aware that depending on how to interact with your chroot you might LOSE ALL OF YOUR PERSONA DATA.
Specially when you mount the full /home under the chroot as it's described here.
That's how the current Rescatux development implements it though.

# Buster i386 Chroot

## Generate chroot base

```
debootstrap --arch i386 buster buster_chroot http://http.debian.net/debian/
```

## Enter folder and gather current directory

```
cd buster_chroot
pwd
```

which outputs for us:
```
/home/rescatuxs/gnu/rescatux/chroots/buster_chroot
```


## Fstab tweak

Then we need to prepare our fstab to take care of mounting some auxiliar folders for the chroot so that it works ok. You can opt to mount them manually if you are not fancing of fstab doing it automatically. Please type all the command as root user

```
cat << EOF | sudo tee -a /etc/fstab
/proc   /home/rescatuxs/gnu/rescatux/chroots/buster_chroot/proc none bind,private 0 0
/dev    /home/rescatuxs/gnu/rescatux/chroots/buster_chroot/dev none bind,private 0 0
/dev/pts        /home/rescatuxs/gnu/rescatux/chroots/buster_chroot/dev/pts none bind,private 0 0
/dev/shm /home/rescatuxs/gnu/rescatux/chroots/buster_chroot/dev/shm none bind,private 0 0
EOF
```

I personally also add the home directory because I found it easier to work with from my main system. Be aware that '''you can delete all your files if you don't umount it before deleting the whole chroot'''.

```
cat << EOF | sudo tee -a /etc/fstab
/home   /home/rescatuxs/gnu/rescatux/chroots/buster_chroot/home none bind,private 0 0
EOF
```

Then you need to mount all thes/home/rescatuxs/gnu/rescatux/chroots/buster_chroote mounts with:
```
mount -a
```

## Custom your Buster Chroot

In order to enter into the Chroot you need to do:

```
chroot /home/rescatuxs/gnu/rescatux/chroots/buster_chroot /bin/bash
```

Once inside the chroot:
I add my usual user (which happens to be 1004 UID so that's ok with home files)
```
groupadd myuser --gid 1004
adduser myuser --uid 1004 --gid 1004
```

I make sure that resolv.conf has a working nameserver
```
nano /etc/resolv.conf
```
* I install sudo package
```
apt-get install sudo
```
* I setup sudo so that my normal user has sudo permissions
```
usermod -a -G sudo myuser
```
* I modify the chroot name so that I am aware of it
```
nano /etc/debian_chroot
```
I write:
```
Buster i386
```
inside of it.

* Take rid of perl warning messages:
```
apt-get install debconf
apt-get install locales
dpkg-reconfigure locales
```

Select only:
```
en_US.UTF-8 UTF-8
```
and then press OK.

Then choose:
```
en_US.UTF-8 UTF-8
```
as your default locale.

Now we need to edit:
```
/root/.bashrc
```
to add there:
```
export LANG="en_US.UTF-8"
```
.

In order to apply the new locales you need to exit the chroot with:
```
exit
```
and re-enter it with:
```
chroot /home/rescatuxs/gnu/rescatux/chroots/buster_chroot /bin/bash
```

If I am inside the chroot and I want to work as my new normal user I can run:
```
su - myuser
```
.

## Post Chroot improvements

These are Rescatux specific requirements based on main README.
From now on this is more like an applied howto of README instructions.
We are still inside the chroot.

### Package requirements
```
apt-get install live-build imagemagick syslinux syslinux-utils
```

### Multiarch requirement

```
dpkg --add-architecture amd64
apt-get update
```
