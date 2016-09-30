#sudo apt-cache depends ubuntu-desktop | grep Depends: | sed s/Depends:\ // | sed s/,// | xargs sudo apt-get -y autoremove
sudo apt-cache depends ubuntu-desktop | grep Recommends: | sed s/Recommends:\ // | sed s/,// | xargs sudo apt-get -y autoremove
