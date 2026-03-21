#!/bin/sh
# Use with care, have not tried yet on a live system, only vm so far
# TODO: is the installboot working?
version=10.0
arch=amd64
doas pkgin install -y wget
wget -r --no-parent --no-check-certificate http://ftp.fr.netbsd.org/pub/NetBSD/NetBSD-$version/$arch/binary/sets/ > /dev/null

doas mv /netbsd /netbsd.old

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

echo "http://cdn.NetBSD.org/pub/pkgsrc/packages/NetBSD/$arch/$version/All" > /usr/pkg/etc/pkgin/repositories.conf
doas pkgin update && doas pkgin upgrade
