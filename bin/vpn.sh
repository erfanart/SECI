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
    echo -e "  ${GREEN}show${NC}            - Display the current VPN settings."
    echo -e "  ${GREEN}cmd${NC}             - Open VPN command mode."
}

# Function to check VPN configuration
check_conf() {
    local action="$1"
    local script="$2"
    local client_config="$3"

    if [[ -n "$client_config" && -f "$client_config" ]]; then
        bash "$CLIENT_DIR/$script" "$client_config"
    elif [[ -f "$MAIN_CLIENT_CONFIG" ]]; then
        bash "$CLIENT_DIR/$script" "$MAIN_CLIENT_CONFIG"
    else
        echo -e "${YELLOW}Changing default VPN client...${NC}"
        bash "$CLIENT_DIR/vpn-choice.sh" "$VPN_CONFIG"
        /bin/vpn "$action"
    fi
}

# Check if the VPN config file exists
if [[ ! -f "$VPN_CONFIG" ]]; then
    echo -e "${RED}Error: VPN configuration file not found: $VPN_CONFIG${NC}"
    exit 1
fi

# Load configuration
source "$VPN_CONFIG"
echo $MAIN_CLIENT_CONFIG
while IFS='=' read -r key value; do
    [[ -n "$key" ]] && declare -x "$key=$(sed 's/"//g' <<< "$value")"
done < "$VPN_CONFIG"

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
    edit)    echo -e "${YELLOW}Editing VPN client...${NC}"; bash "$CLIENT_DIR/vpn-edit.sh" "$VPN_CONFIG" ;;
    show)    echo -e "${GREEN}Showing VPN client...${NC}"; bash "$CLIENT_DIR/vpn-show.sh" "$VPN_CONFIG" ;;
    cmd)     
        echo -e "${GREEN}Switching to command mode...${NC}"
        "$CLIENT_DIR/vpnclient" start
        "$CLIENT_DIR/vpncmd" /CLIENT localhost /CMD
        ;;
    *) 
        echo -e "${RED}Invalid input!${NC}"
        show_help
        exit 1
        ;;
esac
