FROM composer AS composer

# copying the source directory and install the dependencies with composer
COPY . /app

# run composer install to install the dependencies
RUN composer install --no-dev --optimize-autoloader

FROM phpearth/php:7.3-nginx
LABEL Maintainer="Dragan Jovanovic <webstack9@gmail.com>" \
      Description="Lightweight container with Nginx 1.18 & PHP-FPM 7.3 based on Alpine Linux Laravel Multi Stage."

# Install packages and remove default server definition
RUN rm /etc/nginx/conf.d/default.conf

# Configure nginx
COPY docker/config/nginx.conf /etc/nginx/conf.d/default.conf

# Configure PHP-FPM
COPY docker/config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY docker/config/php.ini /etc/php.ini

# Add application
WORKDIR /usr/share/nginx/html

RUN mkdir -p /run/nginx && chown -R nginx:nginx /run/nginx && chown -R nginx:nginx /usr/share/nginx/html \
           && mkdir -p /usr/share/nginx/html/var && chmod -R 777 /usr/share/nginx/html/var \
           && chown -R nginx:nginx /usr/share/nginx/html/var

#COPY --chown=nobody . /var/www/html/
COPY --chown=nginx --from=composer /app /usr/share/nginx/html
#RUN chown -R nginx.nginx /var/www/html/storage /var/www/html/bootstrap/cache

# Expose the port nginx is reachable on
#EXPOSE 8080
