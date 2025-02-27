#!/bin/bash

APP_DIR="/app"
LOG_FILE="/var/log/permissions.log"

echo "Starting file watcher for ${APP_DIR}"

# Function to fix permissions
fix_permissions() {
    local path="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Fixing permissions for: $path" | tee -a "$LOG_FILE"
    
    if [ -d "$path" ]; then
        chmod -v 755 "$path" 2>&1 | tee -a "$LOG_FILE"
    else
        chmod -v 644 "$path" 2>&1 | tee -a "$LOG_FILE"
    fi
}

# Initial permissions fix
echo "$(date '+%Y-%m-%d %H:%M:%S') - Initial permission fix" | tee -a "$LOG_FILE"
find "$APP_DIR" -type d -exec chmod 755 {} \;
find "$APP_DIR" -type f -exec chmod 644 {} \;

# Watch for changes using inotifywait
inotifywait -m -r -e modify,create,attrib "$APP_DIR" | while read -r directory events filename; do
    path="${directory}${filename}"
    fix_permissions "$path"
done 