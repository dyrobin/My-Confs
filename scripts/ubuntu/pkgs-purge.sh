#! /bin/bash

# Ubuntu is required
test -f /etc/lsb-release && . /etc/lsb-release
if [ "Ubuntu" != "$DISTRIB_ID" ]; then
    echo "This script requires Ubuntu."
    exit 1
fi

if [ $# -ne 1 ]; then
    echo "Usage: $0 list|purge"
    exit 1
fi

PKGS=$(dpkg --list | grep "^rc" | cut -d " " -f 3)

case "$1" in
# list packages that will be purged
list)
    if [ -n "$PKGS" ]; then
        echo "$PKGS"
    else
        echo "Nothing needs to be cleaned."
    fi
    ;;
# purge packages
purge)
    test -n "$PKGS" && { echo "$PKGS" | xargs sudo dpkg --purge ; }
    ;;
*)
    echo "Invalid option. Usage: $0 list|purge"
    ;;
esac 
