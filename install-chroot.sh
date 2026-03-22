#!/bin/sh
# From https://www.unitedbsd.com/d/771-netbsd-desktop-part-1-manual-netbsd-installation-on-gptuefi
version=10.0
arch=amd64
ip=192.168.0.99
if=wm0
usr=smurfd
host=flag.net
rout=192.168.0.1
pkgrel=2025Q4
disc=dk0
cat > /etc/fstab << EOF
/dev/{$disc}b               /       ffs     rw               1 1
/dev/{$disc}c               none    swap    sw,dp            0 0
/dev/{$disc}d               /usr    ffs     rw               1 2
/dev/{$disc}e               /var    ffs     rw               1 2
/dev/{$disc}f               /home   ffs     rw               1 2
kernfs                  /kern   kernfs  rw
ptyfs                   /dev/pts        ptyfs   rw
procfs                  /proc   procfs  rw
/dev/cd0a               /cdrom  cd9660  ro,noauto
tmpfs                   /var/shm        tmpfs   rw,-m1777,-sram%25               
EOF

passwd root
echo "encoding $layout" >> /etc/wscons.conf
echo "setvar  wskbd   bell.volume     0"  >> /etc/wscons.conf
echo "setvar  wskbd   bell.pitch         0"  >> /etc/wscons.conf
echo "setvar  wskbd   repeat.del1     250"  >> /etc/wscons.conf
echo "setvar  wskbd   repeat.deln      30"  >> /etc/wscons.conf
ln -sf  /usr/share/zoneinfo/${region}/${state} /etc/localtime


echo "export LANG=\"en_US.UTF-8\"" >> /etc/profile
echo "export LC_CTYPE=\"en_US.UTF-8\"" >> /etc/profile
echo "export LC_ALL=\"\"" >> /etc/profile

cat > /etc/rc.conf << EOF
if [ -r /etc/defaults/rc.conf ]; then
        . /etc/defaults/rc.conf
fi
rc_configured=YES
hostname=$host
defaultroute=$rout
clear_tmp=YES
random_seed=YES
random_file=/etc/entropy-file
wscons=YES
EOF

cat > /etc/resolv.conf << EOF
domain $rout
nameserver $rout
EOF

cat > /etc/ifconfig.$if << EOF
up
media autoselect
$ip netmask 0xffffff00 media autoselect
EOF

echo "$ip         $hostname  $hostname.$domain.$extension" >> /etc/hosts

useradd -g wheel -G users -s /bin/${shell} -c "foo's real name" -m $usr 
passwd $usr

ifconfig $if up $ip netmask 0xffffff00 media autoselect

ftp ftp://ftp.NetBSD.org/pub/pkgsrc/pkgsrc-${pkgrel}/pkgsrc.tar.gz 
tar -xzf pkgsrc.tar.gz -C /usr 
rm pkgsrc.tar.gz

wget --no-check-certificate -r --no-parent -A "pkgin-*.*.*.tgz" "https://cdn.netbsd.org/pub/pkgsrc/packages/NetBSD/$arch/$version/All/"
doas tar zxf cdn.netbsd.org/pub/pkgsrc/packages/NetBSD/$arch/$version/All/pkgin-*.*.*.tgz -C /usr
doas rm -- /usr/+*

echo "http://cdn.NetBSD.org/pub/pkgsrc/packages/NetBSD/$arch/$version/All" > repo.conf
doas cp -f /usr/pkg/etc/pkgin/repositories.conf /usr/pkg/etc/pkgin/repositories.conf.$today
doas cp repo.conf /usr/pkg/etc/pkgin/repositories.conf
