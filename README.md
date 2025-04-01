# Soft Ether VPN Soft Ether Client Control Script

## Overview

This Bash script provides a command-line interface for managing a VPN client. It allows users to start, stop, set up, edit, remove, and configure VPN settings using a configuration file. It also supports fetching and updating Iran IP subnets.

## Features

- Start and stop the VPN client.
- Change and edit the VPN configuration.
- Automatically detect the default gateway.
- Support for updating Iran IP address subnets.
- Interactive command mode for advanced VPN management.
- Configuration loading from a structured file.

## Installation

just command below:

```bash
sudo bash -c "$(curl -sf https://raw.githubusercontent.com/erfanart/SECI/master/installer.sh)"
```

## Usage

Run the script with one of the following commands:

```sh
vpn {start|stop|setup|change|remove|edit|getir|show|cmd}
```

### Commands

| Command          | Description                                              |
| ---------------- | -------------------------------------------------------- |
| `start [config]` | Starts the VPN using the specified or default config.    |
| `stop [config]`  | Stops the VPN.                                           |
| `setup`          | Sets up the VPN client.                                  |
| `change`         | Changes the default VPN client.                          |
| `remove`         | Removes the VPN client.                                  |
| `edit`           | Edits the VPN configuration.                             |
| `getir`          | Fetches or updates Iran IP subnets.                      |
| `show`           | Displays the current VPN settings.                       |
| `cmd`            | Enters interactive command mode for advanced management. |

## Configuration

The script reads VPN settings from:

```
/opt/VPN/conf/vpn_config
```

Example configuration:

```ini
VPN_SERVER="vpn.example.com"
LOCAL_GATEWAY="None"
CLIENT_DIR="/opt/VPN/client"
MAIN_CLIENT_CONFIG="/opt/VPN/conf/main_config"
```

## How It Works

- The script sources the `vpn_config` file.
- It exports the necessary environment variables.
- The `check_conf` function ensures the correct configuration is used.
- If `LOCAL_GATEWAY` is `"None"`, the script automatically detects the default gateway.
- Commands are processed through `case` statements.

## Example Usage

Start the VPN:

```sh
vpn start /path/to/config
```

Stop the VPN:

```sh
vpn stop
```

Change VPN client:

```sh
vpn change
```

Edit configuration:

```sh
vpn edit
```

<!-- ## License

This project is open-source and available under the [MIT License](LICENSE). -->

---

For any issues or contributions, feel free to open a pull request or issue.
