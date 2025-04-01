#!/bin/bash
# Load the configurations file
directory=$CONF_DIR


ask_question() {
		while true; do
    		read -rp "$1 (Y/n) [ default is n ]: " response
    		case ${response,,} in
        			y) return 0;;
        			n|"") return 1;;
        			* ) echo "لطفاچرت و پرت وارد نکنید😐";
   			esac
		done;
}




remove-client(){
source $1
# Stop the SoftEther client (if running)
sudo $CLIENT_DIR/vpnclient stop

sleep 2

# Start the SoftEther client
sudo $CLIENT_DIR/vpnclient start

sleep 3

# Delete the VPN Account info
$CLIENT_DIR/vpncmd /CLIENT localhost /CMD AccountDelete $ACCOUNT_NAME

sleep 2

# Delete the virtual network interface
$CLIENT_DIR/vpncmd /CLIENT localhost /CMD NicDelete $NIC_NAME

sleep 2

# Stop the SoftEther client
sudo $CLIENT_DIR/vpnclient stop

rm $1

}

export -f remove-client
$CLIENT_DIR/vpn-list.sh $1 remove-client $CLIENT_DIR/remove-client.sh

