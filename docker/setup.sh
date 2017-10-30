#!/bin/sh

echo "Creating Laravel Storage"
mkdir -p /var/www/storage/app
mkdir -p /var/www/storage/framework/views
mkdir -p /var/www/storage/framework/cache
mkdir -p /var/www/storage/framework/sessions
mkdir -p /var/www/storage/logs
chmod 777 -R /var/www/storage
chmod 777 -R /var/www/bootstrap/cache

echo "Owning /var/www"
chown -R www-data:www-data /var/www

echo "Generating Laravel App Key.."
php /var/www/artisan key:generate

echo "Done"
