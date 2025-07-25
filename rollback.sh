#!/bin/bash

VERSION=$1
echo "Rolling back to version: $VERSION..."

APP_PATH="/var/www/reactapp"
BACKUP_PATH="/var/www/reactapp_backups"

if [ ! -d "$BACKUP_PATH/$VERSION" ]; then
  echo "Backup version $VERSION does not exist. Aborting rollback."
  exit 1
fi

# Clear current app
sudo rm -rf "$APP_PATH"/*

# Restore backup
sudo cp -r "$BACKUP_PATH/$VERSION"/* "$APP_PATH"/

# Reset ownership
sudo chown -R www-data:www-data "$APP_PATH"

echo "Rollback to version $VERSION completed successfully."
