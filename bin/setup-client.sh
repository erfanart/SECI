#!/bin/bash
# Load the configurations file
ask_question() {

    local question=$1
    local answer

    read -p "$question " answer
    echo "$answer"
}
vpn_name=$(ask_question "Choose name your vpn configs?")
vpn_host=$(ask_question "What is your vpn host?")
vpn_port=$(ask_question "What is your vpn port?")
vpn_hub=$(ask_question "What is your virtual hub?")
username=$(ask_question "What is your username?")
password=$(ask_question "What is your password?")
vpn_config_path=$CONF_DIR/$vpn_name'_config'
echo '''
CLIENT_DIR="${CLIENT_DIR}"
NIC_NAME="${NIC_NAME}"
ACCOUNT_NAME="${ACCOUNT_NAME}"
VPN_HOST_IPv4="${VPN_HOST_IPv4}"
LOCAL_GATEWAY="${LOCAL_GATEWAY}"
DEFAULT_GW="${DEFAULT_GW}"
DESTINATION_HUB="${DESTINATION_HUB}"
VPN_PORT="${VPN_PORT}"
''' > $vpn_config_path


if [[ $vpn_host =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    VPN_IP=$vpn_host
else
    VPN_IP=$(nslookup $vpn_host $current_os_dns| grep -A 2 "Name" | grep Address | awk 'NR==1 {print $2}')
fi

DEFAULT_GW="192.168.30.1"

LAST_GATEWAY=$(ip route | awk '/default/ { print $3 }')

NIC_NAME=${vpn_name,,}
CLIENT_DIR=$CLIENT_DIR
ACCOUNT_NAME=$vpn_name
VPN_HOST_IPv4=$VPN_IP
LOCAL_GATEWAY=$LAST_GATEWAY
DESTINATION_HUB=$vpn_hub
VPN_PORT=$vpn_port
VPN_USERNAME=$username
VPN_PASS=$password
DEFAULT_GW=$DEFAULT_GW



sed -i "s|\${VPN_PORT}|$VPN_PORT|g" $vpn_config_path 
sed -i "s|\${DESTINATION_HUB}|$DESTINATION_HUB|g" $vpn_config_path
sed -i "s|\${NIC_NAME}|$NIC_NAME|g" $vpn_config_path 
sed -i "s|\${CLIENT_DIR}|$CLIENT_DIR|g" $vpn_config_path        
sed -i "s|\${ACCOUNT_NAME}|$vpn_name|g" $vpn_config_path
sed -i "s|\${VPN_HOST_IPv4}|$VPN_IP|g" $vpn_config_path
sed -i "s|\${LOCAL_GATEWAY}|$LAST_GATEWAY|g" $vpn_config_path
sed -i "s|\${DEFAULT_GW}|$DEFAULT_GW|g" $vpn_config_path



# Build the SoftEther client
#make --directory=$CLIENT_DIR

# Wait before executing next step
sleep 2

# Start the SoftEther client
sudo $CLIENT_DIR/vpnclient start

sleep 2

# Check if the SoftEther client is started properly
$CLIENT_DIR/vpncmd /TOOLS /CMD check

sleep 2

# Create a virtual network interface to connect to the VPN server
$CLIENT_DIR/vpncmd /CLIENT localhost /CMD NicCreate $NIC_NAME

sleep 2

# Configure the VPN account info and configs
$CLIENT_DIR/vpncmd /CLIENT localhost /CMD AccountCreate $ACCOUNT_NAME /SERVER:$VPN_HOST_IPv4:$VPN_PORT /HUB:$DESTINATION_HUB /USERNAME:$VPN_USERNAME  /NICNAME:$NIC_NAME

sleep 2

# Configure the VPN server password
$CLIENT_DIR/vpncmd /CLIENT localhost /CMD AccountPassword $ACCOUNT_NAME /PASSWORD:$VPN_PASS /TYPE:standard

