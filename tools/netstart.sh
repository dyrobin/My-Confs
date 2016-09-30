#! /bin/sh
sudo ethtool -s eth0 speed 100 duplex full autoneg on
sudo ifconfig eth0 down
sleep 2
sudo ifconfig eth0 up
