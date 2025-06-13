#!/bin/bash

VPN_CONFIG="/opt/VPN/conf/vpn_config"

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No color

# Function to display help
show_help() {
    echo -e "${YELLOW}VPN Control Script${NC}"
    echo -e "Usage: ${GREEN}$0 {start|stop|setup|change|remove|edit|show|cmd}${NC}"
    echo -e "\nCommands:"
    echo -e "  ${GREEN}start [config]${NC}   - Start the VPN with the specified config file (or default)."
    echo -e "  ${GREEN}stop [config]${NC}    - Stop the VPN using the specified config file (or default)."
    echo -e "  ${GREEN}setup${NC}           - Run the VPN setup script."
    echo -e "  ${GREEN}change${NC}          - Change the default VPN client."
    echo -e "  ${GREEN}remove${NC}          - Remove the VPN client."
    echo -e "  ${GREEN}edit${NC}            - Edit the VPN configuration."
    echo -e "  ${GREEN}edit${NC}            - Get and Update Iran ip address subnets ." 
    echo -e "  ${GREEN}show${NC}            - Display the current VPN settings."
    echo -e "  ${GREEN}cmd${NC}             - Open VPN command mode."
}

# Function to check VPN configuration
check_conf() {
    local action="$1"
    local script="$2"
    local client_config="$3"
    local config_file
    if [[ -n "$client_config" && -f "$client_config" ]]; then
        config_file="$client_config"
    elif [[ -f "$MAIN_CLIENT_CONFIG" ]]; then
        config_file="$MAIN_CLIENT_CONFIG"
    else
        echo "not found :  $MAIN_CLIENT_CONFIG"
        echo -e "${YELLOW}Changing default VPN client...${NC}"
        bash "$CLIENT_DIR/vpn-choice.sh" "$VPN_CONFIG"
        /bin/vpn "$action"
        return
    fi
    while IFS='=' read -r key value; do
            if [ "$key" = "LOCAL_GATEWAY" ]; then
                echo $value
                if [ "$value" == "\"None\"" ]; then
                    value=$(ip -4 route show default | grep -v 'dev vpn' | awk 'NR==1 && /default/ {print $3}')
                else
                    value=$(sed 's/"//g' <<< $value)
                fi
            else
                value=$(sed 's/"//g' <<< $value)
            fi
                [[ -n "$key" ]] && declare -x "$key=$value"
    done < $config_file
    bash "$CLIENT_DIR/$script" 
}

# Check if the VPN config file exists
if [[ ! -f "$VPN_CONFIG" ]]; then
    echo -e "${RED}Error: VPN configuration file not found: $VPN_CONFIG${NC}"
    exit 1
fi

# Load configuration
source "$VPN_CONFIG" 
while IFS='=' read -r key value; do
    [[ -n "$key" ]] && declare -x "$key=$(sed 's/"//g' <<< "$value")"
done < $VPN_CONFIG
# Check if an argument is provided
if [[ -z "$1" ]]; then
    show_help
    exit 1
fi

# Process user commands
case "$1" in
    start)   echo -e "${GREEN}Starting VPN...${NC}"; check_conf "start" "vpn-connect.sh" "$2" ;;
    stop)    echo -e "${GREEN}Stopping VPN...${NC}"; check_conf "stop" "vpn-disconnect.sh" "$2" ;;
    setup)   echo -e "${GREEN}Setting up VPN...${NC}"; bash "$CLIENT_DIR/setup-client.sh" "$VPN_CONFIG" ;;
    change)  echo -e "${YELLOW}Changing default VPN client...${NC}"; bash "$CLIENT_DIR/vpn-choice.sh" "$VPN_CONFIG" ;;
    remove)  echo -e "${RED}Removing VPN client...${NC}"; bash "$CLIENT_DIR/remove-client.sh" "$VPN_CONFIG" ;;
    edit)    echo -e "${YELLOW}Editing VPN client...${NC}"; check_conf "edit" "vpn-connect.sh" "$2" ;;
    getir)   echo -e "${YELLOW}Getting or Update Iran ip subnets ...${NC}"; bash "$CLIENT_DIR/Iran_ips.sh" "$VPN_CONFIG" ;;
    show)    echo -e "${GREEN}Showing VPN client...${NC}"; bash "$CLIENT_DIR/vpn-show.sh" "$VPN_CONFIG" ;;
    cmd)     
        echo -e "${GREEN}Switching to command mode...${NC}"
        "$CLIENT_DIR/vpnclient" start
        "$CLIENT_DIR/vpncmd" /CLIENT localhost /CMD ${@:2}
        ;;
    *) 
        echo -e "${RED}Invalid input!${NC}"
        show_help
        exit 1
        ;;
esac
