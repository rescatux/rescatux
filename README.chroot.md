This README explains how a buster i386 chroot can be setup.
This might not appropiate in most of your systems.
Be aware that depending on how to interact with your chroot you might LOSE ALL OF YOUR PERSONA DATA.
Specially when you mount the full /home under the chroot as it's described here.
That's how the current Rescatux development implements it though.

=== Buster i386 Chroot ===

debootstrap --arch i386 buster buster_chroot http://http.debian.net/debian/
