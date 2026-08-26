#!/usr/bin/env bash

set -euo pipefail

# Detect the real user who started sudo
INSTALL_USER="${SUDO_USER:-$USER}"

# Detect the user's home directory
USER_HOME="$(getent passwd "$INSTALL_USER" | cut -d: -f6)"

SCRIPT_SOURCE="./empty-trash.sh"
SCRIPT_DEST="/usr/local/bin/empty-trash.sh"

SERVICE_SOURCE="./empty-trash.service"
SERVICE_DEST="/etc/systemd/system/empty-trash.service"

echo "Installing for user: $INSTALL_USER"
echo "Home directory: $USER_HOME"

# Check required files
if [[ ! -f "$SCRIPT_SOURCE" ]]; then
    echo "Error: $SCRIPT_SOURCE not found."
    exit 1
fi

if [[ ! -f "$SERVICE_SOURCE" ]]; then
    echo "Error: $SERVICE_SOURCE not found."
    exit 1
fi

# Install the Bash script
sudo cp "$SCRIPT_SOURCE" "$SCRIPT_DEST"
sudo chmod 755 "$SCRIPT_DEST"

# Generate the systemd service
sed \
    -e "s/^User=.*/User=$INSTALL_USER/" \
    -e "s|^Environment=HOME=.*|Environment=HOME=$USER_HOME|" \
    "$SERVICE_SOURCE" |
    sudo tee "$SERVICE_DEST" > /dev/null

# Reload systemd
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable empty-trash.service
sudo systemctl restart empty-trash.service

# Verify installation
if systemctl is-enabled --quiet empty-trash.service &&
   systemctl is-active --quiet empty-trash.service; then
    echo "Installation completed successfully."
else
    echo "Installation failed."
    exit 1
fi
