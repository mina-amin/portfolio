#!/bin/bash

# Database credentials
DB_USER="db_username"
DB_PASS="db_passwd"
DB_NAME="db_name"

# Backup directory
BACKUP_DIR="/dir/bkp"

# Date and time for the backup file
DATE=$(date +"%Y""-""%m""-""%d""-""%H%M%S")
BACKUP_FILE="$BACKUP_DIR/db_bkup_$DATE.sql"

# Run mysqldump to create the backup
mysqldump --user=$DB_USER --password=$DB_PASS --databases $DB_NAME > $BACKUP_FILE

# Optional: Compress the backup file
#gzip $BACKUP_FILE
