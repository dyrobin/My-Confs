#! /bin/bash

# entry format: <hostname user ipAddr macAddr>
hosts_data="
    dyrobin-T410s dyrobin 192.168.1.106 f0def123ca90
    personalcloud dyrobin 192.168.1.110 001075587cd5
    "

# removing leading and trailing spaces as well as blank lines
hosts_data_clean=$(echo "$hosts_data" | sed -e 's/^ *//; s/ *$//; /^$/d')

# $1: hostname 
# $2: the-nth field of entry
# $3: return variable name
function getFieldData() {
    local __retval=$3
    local entry=$(echo "$hosts_data_clean" | grep "^$1 ")
    if [ -z "$entry" ]; then
        echo "No hostname matched with '$1'."
        return 1
    fi

    if [ $2 -gt 4 ] || [ $2 -lt 1 ]; then
        echo "No valid field '$2'. Must be 1, 2, 3, or 4."
        return 1
    fi

    eval $__retval=$(echo "$entry" | cut -f $2 -d " ")
}

# $1: hostname
# ipaddr can be accessed if return value is 0 (i.e. host is on)
function isOn() {
    echo "Checking if '$1' is power on ..."
    
    local ping_output ping_ok ipaddr_tgt
    ping_output=$(ping -c 1 "$1.local" 2>/dev/null)
    ping_ok=$?

    getFieldData "$1" 3 ipaddr

    if [ $ping_ok -eq 0 ]; then
        ipaddr_tgt=$(echo "$ping_output" | grep -E -o '\(([0-9]{1,3}\.){3}[0-9]{1,3}\)' | sed -e 's/[\(\)]//g')
        if [ "$ipaddr_tgt" != "$ipaddr" ]; then
            echo "IP Address of '$1' is changed to '$ipaddr_tgt'."
            ipaddr=$ipaddr_tgt
        fi
    else
        # Ping domain failed, then ping IP address directly
        if [ -z "$ipaddr" ]; then
            return 1
        fi
        ping -c 1 "$ipaddr" &> /dev/null
        if [ $? -ne 0 ]; then
            return 1
        fi
    fi
}

function listHosts() {
    echo "$hosts_data_clean" | cut -f 1 -d " "
}

# $1: hostname pattern
# $2: control options: on|off|sleep
function ctlHost() {
    hostname=$(listHosts | grep  $1)
    if [ -z "$hostname" ]; then
        echo "No hosts are matched with '$1'. See all hosts by specifying list option."
        return 1
    fi
    if [ $(echo "$hostname" | wc -l) -ne 1 ]; then
        echo "Multiple hosts matched. Use more concrete pattern instead."
        return 1
    fi

    case $2 in
        on)
            isOn "$hostname"
            if [ $? -ne 0 ]; then
                getFieldData "$hostname" 4 macaddr 
                if [ -z "$macaddr" ]; then
                    echo "No mac address was found for '$hostname'."
                    return 2
                fi
                local OS=$(uname -s)
                if [ $OS == "Darwin" ]; then
                    ./wolcmd "$macaddr" 255.255.255.255 255.255.255.255 1234
                elif [ $OS == "Linux" ]; then
                    wakeonlan "$macaddr"
                fi
            else
                echo "Oops. '$hostname' has been on already."
            fi
        ;;
        off)
            isOn "$hostname"
            if [ $? -eq 0 ]; then
                getFieldData "$hostname" 2 username
                if [ -z "$username" ]; then
                    echo "No username was found for '$hostname'."
                    return 2
                fi
                ssh -t "$username"@"$ipaddr" "sudo shutdown now"
            else
                echo "Oops. '$hostname' has been off already."
            fi
        ;;
        sleep)
            isOn "$hostname"
            if [ $? -eq 0 ]; then
                getFieldData "$hostname" 2 username
                if [ -z "$username" ]; then
                    echo "No username was found for '$hostname'."
                    return 2
                fi
                # Try invoking different command for different os
                ssh -t "$username"@"$ipaddr" "sudo pm-suspend || sudo shutdown -s now"
            else
                echo "Oops. '$hostname' has been off already."
            fi
        ;;
        *)
            echo "No valid option '$2'. Only supports on|off|sleep"
        ;;
    esac
}

# main
if [ $# -eq 1 ] && [ $1 == "list" ]; then
    listHosts
elif [ $# -eq 2 ]; then
    ctlHost "$1" "$2"
else
    cmd=$(basename $0)
    echo "Usage: $cmd list"
    echo "       $cmd <hostname> on|off|sleep"
    exit 1
fi

