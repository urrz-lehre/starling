FROM php:8.2-apache

ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies.
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    git bc default-mysql-client-core apt-transport-https locales locales-all \
    gettext libcurl4-openssl-dev libfreetype6-dev libicu-dev libjpeg62-turbo-dev \
    libldap2-dev libmariadb-dev libmemcached-dev libpng-dev libpq-dev libxml2-dev libxslt-dev \
    uuid-dev libpq5 libmariadb3 ghostscript libcurl4 libgss3 libmcrypt-dev libxml2 libxslt1.1 \
    libzip-dev sassc unzip zip libmemcached11 libmemcachedutil2 libldap2 libicu76 libaio-dev
RUN apt-get autoremove -y && apt-get clean

# Install php extensions.
RUN docker-php-ext-configure zip --with-zip
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
RUN docker-php-ext-configure ldap

RUN docker-php-ext-install -j$(nproc) exif intl mysqli opcache pgsql soap xsl zip gd ldap
RUN pecl install apcu igbinary memcached pcov solr timezonedb uuid xdebug xhprof
RUN docker-php-ext-enable apcu igbinary memcached pcov solr timezonedb uuid

# Configure php extensions.

RUN echo "apc.enable_cli = On" >> /usr/local/etc/php/conf.d/10-docker-php.ini && \
    echo "pcov.enabled=0" >> /usr/local/etc/php/conf.d/10-docker-php.ini && \
    echo "pcov.exclude='~\/(tests|coverage|vendor|node_modules)\/~'" >> /usr/local/etc/php/conf.d/10-docker-php.ini && \
    echo "pcov.directory=." >> /usr/local/etc/php/conf.d/10-docker-php.ini && \
    echo "pcov.initial.files=1024" >> /usr/local/etc/php/conf.d/10-docker-php.ini && \
    echo "max_input_vars = 5000" >> /usr/local/etc/php/conf.d/10-docker-php.ini && \
    echo "upload_max_filesize = 200M" >> /usr/local/etc/php/conf.d/10-docker-php.ini && \
    echo "post_max_size = 206M" >> /usr/local/etc/php/conf.d/10-docker-php.ini

RUN mkdir /var/www/moodledata && chown www-data /var/www/moodledata && \
    mkdir /var/www/phpunitdata && chown www-data /var/www/phpunitdata && \
    mkdir /var/www/behatdata && chown www-data /var/www/behatdata && \
    mkdir /var/www/behatfaildumps && chown www-data /var/www/behatfaildumps && \
    mkdir /var/www/.npm && chown www-data /var/www/.npm && \
    mkdir /var/www/.nvm && chown www-data /var/www/.nvm

RUN chmod 777 /tmp && chmod +t /tmp

# Perform cleanup.
RUN pecl clear-cache
RUN apt-get remove --purge -y gettext libcurl4-openssl-dev libfreetype6-dev libicu-dev libjpeg62-turbo-dev libldap2-dev libmariadb-dev libmemcached-dev libpng-dev libpq-dev libxml2-dev libxslt-dev uuid-dev
RUN apt-get autoremove -y
RUN apt-get clean

COPY . /app

CMD ["apache2-foreground"]
ENTRYPOINT ["/app/entrypoint.sh"]

