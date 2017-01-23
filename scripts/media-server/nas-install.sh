#! /bin/bash

# Superuser permission under Linux is required to run this script
if [ "root" != $(whoami) ] || [ "Linux" != $(uname -s) ]; then
    echo "This script requires 'root' permission under 'Linux'."
    exit 1
fi

# create mount point
mkdir -p /media/nas

# check mount point in /etc/fstab
grep "[[:space:]]/media/nas[[:space:]]" /etc/fstab > /dev/null && { echo "'/media/nas' exists in /etc/fstab."; exit 1; }

# get group id of sambashare
GID=$(grep sambashare /etc/group | cut -d : -f 3)
test -z "$GID" && { echo "group 'sambashare' does not exist."; exit 1; }

# edit /etc/fstab
cat >> /etc/fstab << ENDOFCONF
# NAS device (samba)
//personalcloud.local/public    /media/nas      cifs    guest,gid=$GID,file_mode=0664,dir_mode=0775,iocharset=utf8  0  0
ENDOFCONF

# mount
mount -a

