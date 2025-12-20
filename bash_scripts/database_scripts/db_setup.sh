#!/bin/bash

# Usage: ./secure_mysql.sh root_password db_name db_user db_pass

DB_ROOT_PASS="$1"
DB_NAME="$2"
DB_USER="$3"
DB_PASS="$4"

if [ -z "$DB_ROOT_PASS" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ]; then
  echo "Usage: $0 <root_password> <db_name> <db_user> <db_pass>"
  exit 1
fi

echo "Securing MySQL installation..."

mysql -u root <<MYSQL_SCRIPT
-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';

-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- Remove test database
DROP DATABASE IF EXISTS test;

-- Remove privileges on test database
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';

-- Reload privilege tables
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "MySQL secure installation completed!"

echo "Creating database and user..."

# Create database
mysql -u root -p"$DB_ROOT_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

# Create user
mysql -u root -p"$DB_ROOT_PASS" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"

# Grant privileges
mysql -u root -p"$DB_ROOT_PASS" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost'; FLUSH PRIVILEGES;"

echo "Database '$DB_NAME' and user '$DB_USER' created successfully!"

echo "Database setup completed!"