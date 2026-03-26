#!/bin/sh
# From https://www.unitedbsd.com/d/771-netbsd-desktop-part-1-manual-netbsd-installation-on-gptuefi
disc=ld0
today=`date +"%y-%m-%d"`
gpt destroy $disc
gpt create -f $disc

# create partitions
gpt add -a 2m -s 65536 -t efi -l "ESP" $disc
gpt add -a 2m -s 5g -t ffs -l "netbsd-root" $disc
gpt add -a 2m -s 8g -t swap -l "netbsd-swap" $disc
gpt add -a 2m -s 5g -t ffs -l "netbsd-var" $disc
gpt add -a 2m -s 20g -t ffs -l "netbsd-usr" $disc
gpt add -a 2m -t ffs -l "netbsd-home"

# format partitions
newfs_msdos -F 16 /dev/dk0
newfs -O 2 -V2 -f 2048 /dev/dk1
newfs -O 2 -V2 -f 2048 /dev/dk3
newfs -O 2 -V2 -f 2048 /dev/dk4
newfs -O 2 -V2 -f 2048 /dev/dk5
swapctl -a -p 1 /dev/dk2

# mount filesystems
mount /dev/dk1 /mnt
cd /mnt 
mkdir var
mkdir usr
mkdir home
swapon /dev/dk2
mount /dev/dk3 /mnt/var
mount /dev/dk4 /mnt/usr
mount /dev/dk5 /mnt/home

# setup install network
ifconfig wm0 192.168.0.98 netmask 0xffffff00
route add default 192.168.0.1

# extract binary sets
cd /tmp
ftp ftp://ftp.netbsd.org/pub/NetBSD/NetBSD-10.0/amd64/binary/sets/*
sha512sum --check SHA512
cd /mnt
for set in kern-GENERIC base comp etc games man misc modules tests text xbase xcomp xetc xfont xserver; do
  > tar -xzpf /tmp/$set.tar.xz
  > done
mv netbsd netbsd.$today && ln -fh netbsd.$today netbsd

# setup bootloader
mount -t msdos /dev/dk0 /media
mkdir -p  /media/EFI/boot
cp /usr/mdec/*.efi /media/EFI/boot

cat > /media/EFI/boot/boot.cfg << EOF
menu=Boot normally:rndseed /etc/entropy-file;boot hd0b:netbsd
menu=Boot single user:rndseed /etc/entropy-file;boot hd0b:netbsd -s
menu=Disable ACPI:rndseed /etc/entropy-file;boot hd0b:netbsd -2
menu=Disable ACPI and SMP:rndseed /etc/entropy-file;boot hd0b:netbsd -12
menu=Drop to boot prompt:prompt
default=1
timeout=5
clear=1
EOF	

installboot -v /dev/dk1 /mnt/usr/mdec/bootxx_ffsv2

# create dev
cd /mnt/dev
sh MAKEDEV all

# setup chroot
mkdir /mnt/kern
mkdir /mnt/proc
mount_kernfs  kernfs   /mnt/kern
mount_procfs  procfs   /mnt/proc
mount_tmpfs  tmpfs   /mnt/var/shm
mount_ptyfs  ptyfs   /mnt/dev/pts
cp install-chroot.sh /mnt
chroot  /mnt su -
echo "Run: sh /install-chroot.sh from within the chroot"
