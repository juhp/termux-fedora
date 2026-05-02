#!/data/data/com.termux/files/usr/bin/bash

set -e -x

TERMUX_BINDIR=/data/data/com.termux/files/usr/bin
STARTFEDORA=$TERMUX_BINDIR/fedora
FEDORA=~/fedora
CWD=$PWD

set_vars() {
    case "$1" in
        43)
            RELEASE=1.6
            BLOB=a05f025c9418cc4a7001631fab932e61d2b1130900e93a06a46ddacd84f6c217
            ;;
        44)
            RELEASE=1.7
            BLOB=a98d584a20692d8c0aed91d18c87b84b89f1183f3eb7241626ffbe1cd4f664ec
            ;;
    esac
    URL="https://download.fedoraproject.org/pub/fedora/linux/releases/$1/Container/aarch64/images/Fedora-Container-Base-Generic-$1-$RELEASE.aarch64.oci.tar.xz"
}

# input validator and help
case "$1" in
    43|44)
        set_vars $1
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
    check-urls)
        for ver in 43 44; do
            set_vars $ver
            curl -I -L $URL
        done
        exit 0
        ;;
    script)
        ;;
    *)
        echo $"Usage: $0 {43|44|removal}"
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
    if ! type proot; then
        pkg install proot tar wget -y
    fi

    mkdir $FEDORA
    cd $FEDORA
    # get the container image
    wget $URL -O fedora.tar.xz

    # extract the Docker image
    tar xvf fedora.tar.xz --exclude json

    # extract the rootfs (ignore tz hard link errors)
    tar xpf blobs/sha256/$BLOB 2>/dev/null || :

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

case "$1" in
    4*) echo "Start Fedora with '$(basename $STARTFEDORA)'. Get updates with regular 'dnf update'." ;;
esac
