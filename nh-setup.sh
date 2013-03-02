#!/bin/sh

nhdir="nethack-3.4.3"
nharchive="nethack-343-src.tgz"
dlurl="http://downloads.sourceforge.net/project/nethack/nethack/3.4.3/nethack-343-src.tgz"
patchdir="patches"

apply_default_patch () {
    for i in `grep "^[^#]" $patchdir/patch.conf`; do
        echo "Applying $i..."
		patch -Nu -r - -p0 < $i > /dev/null
    done
}

apply_patch_i () {
    for i in `ls $patchdir/*.patch`; do
        read -p "Apply $i? [Y/n]" yn

        case $yn in
            Y|y|"" ) patch -Nu -r - -p0 < $i > /dev/null;;
            * ) ;;
        esac
    done
}

dl_nethack () {
    if [ ! -e $nharchive ]; then
        read -p "$nharchive not found, automatically download it now? [Y/n]" yn

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


if [ $reuse = 0 ]; then
    echo "Running NetHack's setup script... "
    cd $nhdir
    sh sys/unix/setup.sh
    cd ..
    patch -p0 < install/linux_install.patch
	patch -p0 < install/pfamain.patch
	patch -p0 < install/middleman.patch
	patch -p0 < install/game_statistics.patch
	patch -p0 < install/game_seed.patch
	echo "Replacing $nhdir/src/Makefile..."
	cp -r install/nh/* $nhdir
fi

if [ -d $patchdir ]; then
	read -p "Apply default patches? [Y/n]" yn

	case $yn in
		Y|y|"" ) apply_default_patch;;
        * ) apply_patch_i ;;
	esac
fi

cd $nhdir && make && make install

if [ $? = 0 ]; then
	echo ""
	echo "************************************************"
    echo "Nethack run script installed in $nhdir"
fi
