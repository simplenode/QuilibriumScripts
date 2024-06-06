#!/bin/bash

# Set service file path
SERVICE_FILE="/lib/systemd/system/ceremonyclient.service"
# User working folder
HOME=$(eval echo ~$USER)
# Node path
NODE_PATH="$HOME/ceremonyclient/node" 

VERSION=$(cat $NODE_PATH/config/version.go | grep -A 1 "func GetVersion() \[\]byte {" | grep -Eo '0x[0-9a-fA-F]+' | xargs printf "%d.%d.%d")

# Get the system architecture
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    EXEC_START="$NODE_PATH/node-$VERSION-linux-amd64"
elif [ "$ARCH" = "aarch64" ]; then
    EXEC_START="$NODE_PATH/node-$VERSION-linux-arm64"
elif [ "$ARCH" = "arm64" ]; then
    EXEC_START="$NODE_PATH/node-$VERSION-darwin-arm64"
else
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
fi

# Function definitions
install_prerequisites() {
    echo "Running installation script for server prerequisites..."
    wget --no-cache -O - https://raw.githubusercontent.com/lamat1111/quilibriumscripts/master/server_setup.sh | bash
}

install_node() {
    echo "Running installation script for Quilibrium Node..."
    wget --no-cache -O - https://raw.githubusercontent.com/lamat1111/QuilibriumScripts/master/qnode_service_installer.sh | bash
}

configure_grpcurl() {
    echo "Running configuration script for gRPCurl..."
    wget --no-cache -O - https://raw.githubusercontent.com/lamat1111/quilibriumscripts/master/tools/qnode_gRPC_calls_setup.sh | bash
}

update_node() {
    echo "Running update script for Quilibrium Node..."
    wget --no-cache -O - https://raw.githubusercontent.com/lamat1111/QuilibriumScripts/master/qnode_service_update.sh | bash
}

check_visibility() {
    echo "Checking visibility of Quilibrium Node..."
    wget -O - https://raw.githubusercontent.com/lamat1111/QuilibriumScripts/main/tools/qnode_visibility_check.sh | bash
}

node_info() {
    echo "Displaying information about Quilibrium Node..."
    cd $EXEC_START && ./node-info
}

node_logs() {
    echo "Displaying logs of Quilibrium Node..."
    sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat
}

restart_node() {
    echo "Restarting Quilibrium Node service..."
    service ceremonyclient restart
}

stop_node() {
    echo "Stopping Quilibrium Node service..."
    service ceremonyclient stop
}

peer_manifest() {
    echo "Checking peer manifest (Difficulty metric)..."
    wget --no-cache -O - https://raw.githubusercontent.com/lamat1111/quilibriumscripts/main_new/tools/qnode_peermanifest_checker.sh | bash
}

node_version() {
    echo "Displaying Quilibrium Node version..."
    journalctl -u ceremonyclient -r --no-hostname  -n 1 -g "Quilibrium Node" -o cat
}

# Main menu
while true; do
    clear
    
    cat << "EOF"

                  QQQQQQQQQ       1111111   
                QQ:::::::::QQ    1::::::1   
              QQ:::::::::::::QQ 1:::::::1   
             Q:::::::QQQ:::::::Q111:::::1   
             Q::::::O   Q::::::Q   1::::1   
             Q:::::O     Q:::::Q   1::::1   
             Q:::::O     Q:::::Q   1::::1   
             Q:::::O     Q:::::Q   1::::l   
             Q:::::O     Q:::::Q   1::::l   
             Q:::::O     Q:::::Q   1::::l   
             Q:::::O  QQQQ:::::Q   1::::l   
             Q::::::O Q::::::::Q   1::::l   
             Q:::::::QQ::::::::Q111::::::111
              QQ::::::::::::::Q 1::::::::::1
                QQ:::::::::::Q  1::::::::::1
                  QQQQQQQQ::::QQ111111111111
                          Q:::::Q           
                           QQQQQQ  QUILIBRIUM.ONE                                                                                                                                  


===================================================================
                      ✨ QNODE QUICKSTART ✨
===================================================================
         Follow the guide at https://docs.quilibrium.one

                      Made with 🔥 by LaMat
====================================================================

EOF

    echo "Please choose an option:"
    echo ""
    echo "If you want install a new node choose option 1, and then 2"
    echo ""
    echo "1) Prepare your server"
    echo "2) Install Node"
    echo ""
    echo "3) Configure gRPCurl"
    echo "4) Update Node"
    echo "5) Check Visibility"
    echo "6) Node Info"
    echo "7) Node Logs"
    echo "8) Restart Node"
    echo "9) Stop Node"
    echo "10) Peer manifest (Difficulty metric)"
    echo "11) Node Version"
    echo "e) Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1) install_prerequisites ;;
        2) install_node ;;
        3) configure_grpcurl ;;
        4) update_node ;;
        5) check_visibility ;;
        6) node_info ;;
        7) node_logs ;;
        8) restart_node ;;
        9) stop_node ;;
        10) peer_manifest ;;
        11) node_version ;;
        e) break ;;
        *) echo "Invalid option, please try again." ;;
    esac

    read -n 1 -s -r -p "Press any key to continue"
done
