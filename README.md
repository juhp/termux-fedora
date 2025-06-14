# termux-fedora
A script to install a Fedora chroot into Termux.

Currently it is preconfigured for Fedora 41 & 42 aarc64 (ARM64),
or you can use any fedora container tarball url.

# Instructions

Inside Termux run:
```
$ pkg install git
$ git clone git://github.com/juhp/termux-fedora
$ termux-fedora/install.sh [f41|f42]
$ fedora
```

To uninstall:
```
$ ./termux-fedora.sh removal
```

Original blog post:
https://nmilosev.svbtle.com/termuxfedora-install-fedora-on-your-phone-with-termux
