#!/bin/sh

if [ "$(ls -A /var/www/html)" ]; then
    find /var/www/html -not -name "config.php" -exec rm -rv {} \;
fi

# Move GRIPS data to /var/www/html.
cp -r /app/* /var/www/html

# Delete potentially invalid files.
rm -f /var/www/html/entrypoint.sh

apache2-foreground
