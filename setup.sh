sudo mkfs.ext4 /dev/pmem0 
sudo mount -o dax /dev/pmem0 /mnt/mem
sudo chown oem /mnt/mem
