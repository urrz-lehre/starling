#!/bin/sh

if [ "$(ls -A /var/www/html)" ]; then
    mv /var/www/html/config.php /tmp/config.php
    rm -rf /var/www/html/*
    mv /tmp/config.php /var/www/html
fi

# Move GRIPS data to /var/www/html.
cp -r /app/* /var/www/html

# Delete potentially invalid files.
rm -f /var/www/html/entrypoint.sh

apache2-foreground
