#!/bin/sh

nh="$HOME/games/nethack"
nhdir="nethack-3.4.3/"
nharchive="nethack-343-src.tgz"
dlurl="http://downloads.sourceforge.net/project/nethack/nethack/3.4.3/nethack-343-src.tgz"
patchdir="../patch/"

apply_patch () {
    for i in `ls $patchdir`; do
        read -p "Apply $i? [Y/n]" yn

        case $yn in
            Y|y|"" ) patch -p2 < $patchdir$i;;
            * ) ;;
        esac
    done
}

dl_nethack () {
    if [ ! -e $nharchive ]; then
        read -p "$nharchive not found, automaticaly download it now? [Y/n]" yn

        case $yn in
            Y|y|"" ) wget $dlurl;;
            * ) exit;;
        esac
    fi

    echo "Extracting... "
    tar -xf $nharchive
}


reuse=0

if [ -d $nhdir ]; then
    read -p "Use existing $nhdir ? [Y/n]" yn

    case $yn in
        Y|y|"" ) reuse=1;;
        N|n ) rm -rf $nhdir; dl_nethack;;
        * ) echo "please answer 'y' or 'n'"; exit;;
    esac
else
    dl_nethack
fi


if [ -e $nh ]; then
    read -p "previous nethack installation found at $nh, overwrite? [y/n]" yn

    case $yn in
        Y|y ) ;;
        N|n ) exit;;
        * ) echo "please answer 'y' or 'n'"; exit;;
    esac
fi


if [ $reuse = 0 ]; then
    echo "Running NetHack's setup script... "
    cd $nhdir
    sh sys/unix/setup.sh
    cd ..
    patch -p0 < linux_install.patch
fi

if [ -d $patchdir ]; then
    echo "Applying patches..."
    apply_patch
fi

cd $nhdir && make && make install

if [ $? = 0 ]; then
    echo "Nethack run script installed at $nh"
fi
