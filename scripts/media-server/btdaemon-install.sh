#! /bin/bash

# Ubuntu (>=15.04) is required
test -f /etc/lsb-release && . /etc/lsb-release
if [ "Ubuntu" != "$DISTRIB_ID" ] || [ $(echo "$DISTRIB_RELEASE" | tr -d .) -lt 1504 ]; then
    echo "This script requires Ubuntu (>=15.04)."
    exit 1
fi

# Superuser permission is required
if [ "root" != $(whoami) ]; then
    echo "This script requires 'root' permission."
    exit 1
fi

# install transmission-daemon if needed
test $(dpkg -l | grep transmission-daemon | cut -d ' ' -f 1) != "ii" && apt-get -y install transmission-daemon

# join sambashare to access nas
adduser debian-transmission sambashare

# stop service before edit configuration
systemctl stop transmission-daemon

# edit config of transmission-daemon
# https://github.com/transmission/transmission/wiki/Editing-Configuration-Files
sed -i -e "s/\(\"rpc-authentication-required\": \).*,/\1false,/; s/\(\"rpc-whitelist-enabled\": \).*,/\1false,/" /var/lib/transmission-daemon/info/settings.json

# add drop-in conf for service
mkdir -p /etc/systemd/system/transmission-daemon.service.d
cat > /etc/systemd/system/transmission-daemon.service.d/local.conf << ENDOFCONF
[Service]
Requires=media-nas.mount
After=media-nas.mount
Restart=on-failure
ENDOFCONF

# start service
systemctl daemon-reload
systemctl start transmission-daemon

