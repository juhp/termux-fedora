#!/data/data/com.termux/files/usr/bin/bash

#set -e

TERMUX_BINDIR=/data/data/com.termux/files/usr/bin
STARTFEDORA=$TERMUX_BINDIR/fedora
FEDORA=~/fedora
CWD=$PWD

# input validator and help
case "$1" in
        f41)
            IMAGE=https://download.fedoraproject.org/pub/fedora/linux/releases/41/Container/aarch64/images/Fedora-Container-Base-Generic-41-1.4.aarch64.oci.tar.xz
            BLOB=cab661b116395b168b07a1c4669b842eba6f54f82da27d0cc514db23b19df12a
            ;;
        f42)
            IMAGE=https://download.fedoraproject.org/pub/fedora/linux/releases/42/Container/aarch64/images/Fedora-Container-Base-Generic-42-1.1.aarch64.oci.tar.xz
            BLOB=cfc0be9fb5518ec8eb4521cdb4dc2ee14df42924e0f468d24a8e6cfbdda5fdc9
            ;;
        removal)
            echo "Uninstall with:"
            echo chmod -R 777 $FEDORA
            echo rm -rf $FEDORA
            echo rm -f $STARTFEDORA
            echo "Use 'do-removal' to perform it"
            exit 0
            ;;
        do-removal)
            chmod -R 777 $FEDORA
            rm -rf $FEDORA
            rm -f $STARTFEDORA
            exit 0
            ;;
        script)
            ;;
        *)
            echo $"Usage: $0 {f41|f42|removal}"
            exit 2
            ;;
esac

if [ "$1" = "script" ]; then
    echo "updating 'fedora' script"
elif [ -d "$FEDORA" ]; then
    if [ "$FEDORA" = "$HOME/fedora" ]; then
        fedora='~/fedora'
    else
        fedora=$FEDORA
    fi
    echo "$fedora exists"
    exit 1
else
    # install necessary packages
    if type pkg; then
        PKGMGR=pkg
    else
        PKGMGR=apt
    fi
    $PKGMGR install proot tar wget -y

    mkdir $FEDORA
    cd $FEDORA
    # get the docker image
    wget $IMAGE -O fedora.tar.xz

    # extract the Docker image
    tar xvf fedora.tar.xz --strip-components=1 --exclude json

    # extract the rootfs
    tar xpf blobs/sha256/$BLOB

    # cleanup
    chmod +w .
    rm -r blobs oci-layout
    rm fedora.tar.xz

    # fix DNS
    echo "nameserver 8.8.8.8" > etc/resolv.conf

    echo "installing 'fedora' script"
fi

# make a shortcut
TOP=$(dirname "$0")
cp $CWD/$TOP/fedora $STARTFEDORA
chmod +x $STARTFEDORA

# all done
echo "done"

if [ "$1" != "script" -a "$1" != "uninstall" ]; then
    echo "Start Fedora with '$(basename $STARTFEDORA)'. Get updates with regular 'dnf update'."
fi
