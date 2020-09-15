FROM composer:1.9.0 as build
WORKDIR /app
COPY . /app
RUN composer global require hirak/prestissimo && composer install  \
    --ignore-platform-reqs \
    --no-ansi \
    --no-autoloader \
    --no-dev \
    --no-interaction \
    --no-scripts

FROM php:7.3-apache-stretch
RUN docker-php-ext-install pdo pdo_mysql
RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

EXPOSE 8080
COPY --from=build /app /var/www/
COPY docker/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY docker/build/php.ini ${PHP_INI_DIR}/conf.d/99-overrides.ini
COPY .env.cloudrun /var/www/.env
COPY public/js /var/www/public/js
COPY public/css /var/www/public/css
COPY public/mix-manifest.json /var/www/public/mix-manifest.json
RUN chmod 777 -R /var/www/storage/ && \
    echo "Listen 8080" >> /etc/apache2/ports.conf && \
    chown -R www-data:www-data /var/www/ && \
    a2enmod rewrite
