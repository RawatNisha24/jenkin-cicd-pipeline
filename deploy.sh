#!/bin/bash

ENV=$1

echo "Deploying React app to environment: $ENV..."

APP_PATH="/var/www/reactapp"
SRC_PATH="$(pwd)"  

# Ensure APP_PATH exists
sudo mkdir -p "$APP_PATH"

# Deploy new build
sudo cp -r "$SRC_PATH"/* "$APP_PATH"/

# Set permissions for web server
sudo chown -R www-data:www-data "$APP_PATH"

echo "Deployment to $ENV completed successfully."
