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
