#!/bin/sh
# Use with care, have not tried yet on a live system, only vm so far
version=10.0
arch=amd64
today=`date date +"%y-%m-%d"`
echo Downloading sets...
doas pkgin -y install wget
wget -r --no-parent --no-check-certificate http://ftp.fr.netbsd.org/pub/NetBSD/NetBSD-$version/$arch/binary/sets/ > /dev/null 2>&1
cd ftp.fr.netbsd.org/pub/NetBSD/NetBSD-$version/$arch/binary/sets/

doas mv /netbsd /netbsd.$today
doas mv /boot /boot.$today

doas tar Jxf kern-GENERIC.tar.xz -C /
doas tar Jxf base.tar.xz -C /
doas tar Jxf comp.tar.xz -C /
doas tar Jxf gpufw.tar.xz -C /
doas tar Jxf man.tar.xz -C /
doas tar Jxf misc.tar.xz -C /
doas tar Jxf modules.tar.xz -C /
doas tar Jxf rescue.tar.xz -C /
doas tar Jxf tests.tar.xz -C /
doas tar Jxf text.tar.xz -C /
doas tar Jxf xbase.tar.xz -C /
doas tar Jxf xcomp.tar.xz -C /
doas tar Jxf xfont.tar.xz -C /
doas tar Jxf xserver.tar.xz -C /
echo skipping: debug.tar.xz etc.tar.xz games.tar.xz xdebug.tar.xz xetc.tar.xz
echo Extraction complete
doas installboot -v /dev/rdk0 /usr/mdec/bootxx_ffsv2
doas cp /usr/mdec/boot /boot

echo "http://cdn.NetBSD.org/pub/pkgsrc/packages/NetBSD/$arch/$version/All" > repo.conf
doas cp /usr/pkg/etc/pkgin/repositories.conf /usr/pkg/etc/pkgin/repositories.conf.$today
doas cp repo.conf /usr/pkg/etc/pkgin/repositories.conf
doas pkgin update && doas pkgin upgrade
