sudo umount /dev/sda4
sudo mkfs.ext4 -F /dev/sda4
sudo mount /dev/sda4 /mnt
sudo chmod a+rw /mnt
