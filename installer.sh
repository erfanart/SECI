#!/bin/bash
files_url="https://raw.githubusercontent.com/erfanart/SECI/refs/heads/master/bin"
vpn_path=/opt/VPN
vpn_script_path=$vpn_path/bin
vpn_config_path=$vpn_path/conf/vpn_config
vpn_get_url="https://www.softether-download.com/files/softether/v4.43-9799-beta-2023.08.31-tree/Linux/SoftEther_VPN_Client/64bit_-_Intel_x64_or_AMD64/softether-vpnclient-v4.43-9799-beta-2023.08.31-linux-x64-64bit.tar.gz"
#vpn_get_url="https://docs.basa.ir/vpn/linux/vpn.tar.gz"
check_install(){

if ! dpkg -l $1 &> /dev/null; then
    echo "Installing $1..."
    # Install build-essential
    sudo apt-get install -y build-essential
    echo "$1 installed successfully."
else
    echo "$1 is already installed."
fi
}

ask_question() {

    local question=$1
    local answer

    read -p "$question " answer
    echo "$answer"
}
make_main_scripts(){
cat << 'EOF'

#######################################################
######                                           ######
######           GET MAIN SCRIPTS FILES          ######
######                                           ######
#######################################################

EOF
mkdir -p $vpn_script_path
mkdir -p $vpn_path/conf

BINS=(
    "custom-route.sh"
    "Iran_ips.sh"
    "remove-client.sh"
    "setup-client.sh"
    "vpn-choice.sh"
    "vpn-connect.sh"
    "vpn-disconnect.sh"
    "vpn-edit.sh"
    "vpn-list.sh"
    "vpn-log.sh"
    "vpn.sh"
    "vpn-show.sh"
)
for file in ${BINS[@]}
    do
        echo "get $file" 
        curl -sSf  "$files_url/$file" > $vpn_script_path/$file
    done


cat <<EOF > $vpn_config_path
CLIENT_DIR="$vpn_script_path"
CONF_DIR="$vpn_path/conf"
MAIN_CLIENT_CONFIG=""
EOF

chmod +x $vpn_script_path/*
ln -s $vpn_script_path/vpn.sh /bin/vpn
}
get_vpn_files() {
cat << 'EOF'

#######################################################
######                                           ######
######              GET VPNCLIENT FILES	         ######
######                                           ######
#######################################################
EOF
    mkdir -p $vpn_path
    wget $vpn_get_url -O $vpn_path/vpn.tar.gz
    tar -xvzf $vpn_path/vpn.tar.gz -C $vpn_path/ --transform='s|^vpnclient/|vpn/|'
    mv $vpn_path/vpn $vpn_path/bin
    if check_install build-essential;then
        echo "Makeing VpnClient ..."
        make --directory=$vpn_script_path main
    fi
    chmod +x $vpn_path/*
    make_main_scripts
}

current_os_dns=$(cat /etc/resolv.conf | grep -oP 'nameserver \K\d+\.\d+\.\d+\.\d+' | head -n 1)

echo "dnsserver is $current_os_dns"






operation=$(ask_question "choose operation [ --install | --renew | --uninstall ]:")

case $operation in
    --renew|-r|r)
        rm /bin/vpn
        make_main_scripts
    ;;
    --install|-i|i)
        get_vpn_files
        vpn change
        vpn start

    ;;

    --uninstall|-u|u)
        
        vpn stop
        bash  $vpn_script_path/remove-client.sh
        rm -rf $vpn_script_path
        rm -rf /bin/vpn

    ;;

    *)
        echo "Invalid parameter was passed!"
    ;;

esac
