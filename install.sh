#!/bin/bash 

(
echo o # Create a new empty DOS partition table
echo n # Add a new partition
echo p # Primary partition
echo 1 # Partition number
echo   # First sector (Accept default: 1)
echo +512M # Last sector: 512 MB boot parttion
echo n # Add a new partition
echo p # Primary partition
echo 2 # Partition number
echo   # First sector
echo   # Last sector (Accept default: varies)
echo a # make a partition bootable
echo 1 # bootable partition is partition 1 -- /dev/sda1
echo p # print the in-memory partition table
echo w # Write changes
echo q # Quit
) | sudo fdisk