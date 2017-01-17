#! /bin/bash

# Ubuntu is required
test -f /etc/lsb-release && . /etc/lsb-release
if [ "Ubuntu" != "$DISTRIB_ID" ]; then
    echo "This script requires Ubuntu."
    exit 1
fi

#sudo apt-cache depends ubuntu-desktop | grep Depends: | sed s/Depends:\ // | sed s/,// | xargs sudo apt-get -y autoremove
sudo apt-cache depends ubuntu-desktop | grep Recommends: | sed s/Recommends:\ // | sed s/,// | xargs sudo apt-get -y autoremove
