#!/bin/sh

if [ -z "$(ls -A /var/www/html)" ]; then
    # Move GRIPS data to /var/www/html.
    cp -r /app/* /var/www/html

    # Delete potentially invalid files.
    rm -f /var/www/html/entrypoint.sh
else
    # TODO: We need a proper mechanism to update moodle if the version has been updated.
    echo "/var/www/html is not empty. continuing."
fi

apache2-foreground

