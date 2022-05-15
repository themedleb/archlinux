#!/bin/bash

read -p "Storage device path ('sdX' or 'vdX' or 'nvmeXnY' ...): " storageDevicePath
read -p "Storage encryption password: " storageEncryptionPassword
read -p "Hostname: " hostname
read -p "Root password: " rootPassword
read -p "Username: " userName
read -p "User password: " userPassword
read -p "Graphics driver ('amd' or 'intel' or 'nvidia' or 'allopensource'. Default is 'vm'): " graphicsDriver

if [[ $graphicsDriver == 'amd' ]]
then
graphicsDriverInput="AMD / ATI (open-source)"

elif [[ $graphicsDriver == 'intel' ]]
then
graphicsDriverInput="Intel (open-source)"

elif [[ $graphicsDriver == 'allopensource' ]]
then
graphicsDriverInput="All open-source (default)"

elif [[ $graphicsDriver == 'nvidia' ]]
then
graphicsDriverInput="Nvidia"

else
graphicsDriverInput="VMware / VirtualBox (open-source)"
fi

echo '{"!encryption-password":"'$storageEncryptionPassword'","!root-password":"'$rootPassword'", "!superusers":{},"!users":{"'$userName'": {"!password": "'$userPassword'"}}}' | jq '.' > user_credentials.json

echo '{"/dev/'$storageDevicePath'": {"partitions": [{"boot": true,"encrypted": false,"filesystem": {"format": "fat32"},"mountpoint": "/boot","size": "512MiB","start": "1MiB","type": "primary","wipe": true},{"btrfs": {"subvolumes": {"@": "/","@snapshots": "/.snapshots","@home": "/home","@log": "/var/log","@pkg": "/var/cache/pacman/pkg"}},"encrypted": true,"filesystem": {"format": "btrfs","mount_options": ["compress=zstd"]},"mountpoint": null,"size": "100%","start": "513MiB","type": "primary","wipe": true}],"wipe": true}}' | jq '.' > user_disk_layout.json

sleep 3s
wait

tmp=$(mktemp)

jq '.["harddrives"] = "/dev/'"$storageDevicePath"'"' user_configuration.json > "$tmp" && mv "$tmp" user_configuration.json

jq '.["hostname"] = "'"$hostname"'"' user_configuration.json > "$tmp" && mv "$tmp" user_configuration.json

jq '.["gfx_driver"] = "'"$graphicsDriverInput"'"' user_configuration.json > "$tmp" && mv "$tmp" user_configuration.json

archinstall --config user_configuration.json --creds user_credentials.json --disk_layouts user_disk_layout.json
