#! /bin/sh

if [ $# -ne 1 ]; then
        echo "usage: $0 --list[remove]"
        exit 1
fi

case "$1" in

# list all packages that will be removed completely
--list)
	echo "Listing packages to be removed completely"
	dpkg --list | grep "^rc" | cut -d " " -f 3
	;;
# remove the packages completely
--remove)
	echo "Removing packages"
	dpkg --list | grep "^rc" | cut -d " " -f 3 | xargs sudo dpkg --purge
	;;
*)
	echo "Invalid option"
	echo "usage: $0 --list[remove]"
	;;
esac 
