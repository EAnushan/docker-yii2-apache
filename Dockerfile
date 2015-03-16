FROM debian:jessie

MAINTAINER Anushan Easwaramoorthy <EAnushan@hotmail.com>

# Install packages.
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
	apache2 \
	php5 \
	php5-mysql \
	php5-curl \
	git \
	curl

# Install composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Configure composer.
RUN composer global require "fxp/composer-asset-plugin:1.0.0" --prefer-source --no-interaction

# Enable apache mods.
RUN a2enmod rewrite && a2enmod ssl

# Enable only ssl apache config.
RUN a2dissite 000-default && a2ensite default-ssl.conf

# Expose HTTPS port.
EXPOSE 443

# Copy configs.
COPY default-ssl.conf /etc/apache2/sites-available/default-ssl.conf

# Copy startup script.
COPY start.sh /opt/yii2-apache/

# Copy site files.
ONBUILD COPY . /var/www/yii2site/

# Change working directory.
ONBUILD WORKDIR /var/www/yii2site

# Run composer.
ONBUILD RUN composer install --prefer-source --no-interaction

# Modify folder permissions.
ONBUILD RUN chown www-data:www-data runtime && chown www-data:www-data web/assets

# Start!
CMD ["/bin/bash", "/opt/yii2-apache/start.sh"]
