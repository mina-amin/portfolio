#!/bin/bash
# Script: install_php_version.sh
# Usage: ./install_php_version.sh 8.2

set -e

PHP_VERSION=$1

if [[ -z "$PHP_VERSION" ]]; then
    echo "❌ Usage: $0 <php_version> (e.g. 8.2)"
    exit 1
fi

echo "🔍 Checking availability of PHP $PHP_VERSION..."

sudo apt update -qq

# Function to check if candidate exists
check_candidate() {
    apt-cache policy php${PHP_VERSION} | grep "Candidate:" | awk '{print $2}'
}

PHP_AVAILABLE=$(check_candidate)

# Add Ondřej PPA if needed
if [[ "$PHP_AVAILABLE" == "(none)" || -z "$PHP_AVAILABLE" ]]; then
    echo "⚙️ PHP $PHP_VERSION NOT found in system repo. Adding Ondřej PPA..."
    if ! grep -REq "^deb .+ondrej/php" /etc/apt/sources.list.d 2>/dev/null; then
        sudo add-apt-repository -y ppa:ondrej/php
        sudo apt update -qq
    fi
    PHP_AVAILABLE=$(check_candidate)
    if [[ "$PHP_AVAILABLE" == "(none)" || -z "$PHP_AVAILABLE" ]]; then
        echo "❌ PHP version $PHP_VERSION NOT FOUND even in PPA!"
        exit 1
    fi
fi

echo "📦 Installing PHP $PHP_VERSION + extensions..."
sudo apt install -y \
    zip unzip \
    php${PHP_VERSION} \
    php${PHP_VERSION}-cli php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-mysql php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml \
    php${PHP_VERSION}-bcmath php${PHP_VERSION}-curl \
    php${PHP_VERSION}-gd php${PHP_VERSION}-intl php${PHP_VERSION}-soap \
    php${PHP_VERSION}-readline php${PHP_VERSION}-opcache php${PHP_VERSION}-zip \
    php${PHP_VERSION}-redis php${PHP_VERSION}-memcached

echo "🔄 Enabling and starting PHP-FPM service..."
sudo systemctl enable php${PHP_VERSION}-fpm
sudo systemctl restart php${PHP_VERSION}-fpm

# Update alternatives to make new PHP version default
sudo update-alternatives --install /usr/bin/php php /usr/bin/php${PHP_VERSION} ${PHP_VERSION//./}
sudo update-alternatives --set php /usr/bin/php${PHP_VERSION}

echo "✅ PHP $PHP_VERSION installed and set as default!"
php -v
