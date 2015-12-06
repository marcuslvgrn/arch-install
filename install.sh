#run as root
sudo su
#partition drive
gparted
# mount drive
fdisk -l
mount /dev/sda /mnt
#create subvolumes 
cd /mnt
btrfs subv create root
btrfs subv create boot
btrfs subv create home
cd /
umount /mnt
mount -o subvol=root /dev/sda /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount -o subvol=boot /dev/sda /mnt/boot
mount -o subvol=home /dev/sda /mnt/home

#install base system (non-LTS)
pacstrap -i /mnt base

#lts kernel directly
pacman -Sy
pacstrap /mnt $(pacman -Sqg base | sed 's/^linux$/&-lts/') 

#generate fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

#chroot
arch-chroot /mnt /bin/bash

#generate locale (sv_SE.UTF-8)
sed -i '/sv_SE\.UTF/s/^#//g' /etc/locale.gen
locale-gen

#set locale
echo LANG=sv_SE.UTF-8 > /etc/locale.conf

#set keymap
echo KEYMAP=sv-latin1 > /etc/vconsole.conf

#timezone
ln -s /usr/share/zoneinfo/Europe/Stockholm /etc/localtime

#hwclock
hwclock --systohc --utc

#hostname
echo hostname > /etc/hostname

#dhcp
systemctl enable dhcpcd.service

#initram
mkinitcpio -p linux

#password
passwd

#boot loader (grub)
pacman -S grub efibootmgr os-prober

os-prober
grub-install --target=i386-pc --recheck --debug /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

#Exit from the chroot environment
exit

# Add user
useradd -m -G wheel -s /bin/bash lovgren
passwd lovgren

#sudo
pacman -S sudo
#add sudo for wheel group
sed -i '/NOPASSWD/!s/# %wheel/%wheel/g' /etc/sudoers

#graphic drivers
nvidia:
pacman -S nvidia-340xx (legacy cards like 9800gt)
pacman -S nvidia (newer cards)
intel:
pacman -S xf86-video-intel

#virtualbox
pacman -S virtualbox-guest-utils
echo vboxguest >> /etc/modules-load.d/virtualbox.conf
echo vboxsf >> /etc/modules-load.d/virtualbox.conf
echo vboxvideo >> /etc/modules-load.d/virtualbox.conf

#gnome
pacman -S gnome
systemctl enable gdm.service

#volume level at login
pacman -S alsa-utils

#lxde
pacman -S lxde lxdm
systemctl enable lxdm.service

#Reboot the computer
# reboot
