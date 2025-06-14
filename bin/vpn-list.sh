#!/bin/bash
# Directory containing the files
directory=$CONF_DIR
func=$2

log INFO $CLIENT_DIR

load_function() {
    local function_name="$1"
    local file_name="$2"
    local function_definition
    function_definition=$(sed -n "/^function $function_name()/,/^}/p" "$file_name")
    eval "$function_definition"
}
load_function $2 $3


file_names=()

for file in "$directory"/*; do
    # Check if the item is a file (not a directory)
    if [[ -f $file && $(basename "$file") != "vpn_config" && $(basename "$file") != "custom_ips" ]]; then
        # Extract the file name from the full path and add it to the array
        file_names+=("$(basename "$file")")
    fi
done
if [ "${#file_names[@]}" -gt 0 ]; then
while true;do
for ((i = 0; i < ${#file_names[@]}; i++)); do
    echo "$((i+1)): ${file_names[i]}"
done

echo "Please choose a file (enter the corresponding number): "
default_choice="1"
read -e -p "Enter your choice [default is 1]: " choice
choice="${choice:-$default_choice}"

if [[ $choice =~ ^[0-9]+$ && $choice -ge 1 && $choice -le ${#file_names[@]} ]]; then
    chosen_file="${file_names[choice-1]}"
    log DEBUG "chosed file is: $CONF_DIR/$chosen_file"
    $func "$CONF_DIR/$chosen_file"
    break;
else
    echo "Invalid choice. Please enter a valid number."
fi
done
else
    /bin/vpn setup
fi

