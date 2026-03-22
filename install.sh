#!/bin/sh
# From https://www.unitedbsd.com/d/771-netbsd-desktop-part-1-manual-netbsd-installation-on-gptuefi
disc=dk0
today=`date +"%y-%m-%d"`
gpt destroy $disc
gpt create -f $disc

# create partitions
gpt add -a 2m -s 65536 -t efi -l "ESP" $disc
gpt add -a 2m -s 5g -t ffs -l "netbsd-root" $disc
gpt add -a 2m -s 8g -t swap -l "netbsd-swap" $disc
gpt add -a 2m -s 5g -t ffs -l "netbsd-var" $disc
gpt add -a 2m -s 20g -t ffs -l "netbsd-usr" $disc
gpt add -a 2m -t ffs -l "netbsd-home”

# format partitions
newfs_msdos -F 16 /dev/r{$disc}a
newfs -O 2 -V2 -f 2048 /dev/r{$disc}b
newfs -O 2 -V2 -f 2048 /dev/r{$disc}d
newfs -O 2 -V2 -f 2048 /dev/r{$disc}e
newfs -O 2 -V2 -f 2048 /dev/r{$disc}f
swapctl -a -p 1 /dev/{$disc}c

# mount filesystems
mount /dev/{$disc}b /mnt
cd /mnt 
mkdir {var,usr,home}
swapon /dev/{$disc}c
mount /dev/{$disc}d /mnt/var
mount /dev/{$disc}e /mnt/usr
mount /dev/{$disc}f /mnt/home

# extract binary sets
cd /mnt
for set in KERN-GENERIC base comp etc games man misc modules tests text xbase xcomp xetc xfont xserver; do
  > tar -xzpf /amd64/binary/sets/$set.tar.xz
  > done
mv netbsd netbsd.$today && ln -fh netbsd.$today netbsd

# setup bootloader
mount -t msdos /dev/{$disc}a /media
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

installboot -v /dev/{$disc}b /mnt/usr/mdec/bootxx_ffsv2

# create dev
cd /mnt/dev
sh MAKEDEV all

# setup chroot
mkdir {kern,proc}
mount_kernfs  kernfs   /mnt/kern
mount_procfs  procfs   /mnt/proc
mount_tmpfs  tmpfs   /mnt/var/shm
mount_ptyfs  ptyfs   /mnt/dev/pts
chroot  /mnt su -
