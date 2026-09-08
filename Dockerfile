FROM php:8.3-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
        git unzip zlib1g-dev libzip-dev libpng-dev libjpeg62-turbo-dev \
        libfreetype6-dev libicu-dev libwebp-dev graphicsmagick \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j"$(nproc)" gd intl mysqli pdo_mysql zip opcache \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# TYPO3 serves from public/ and needs mod_rewrite
RUN a2enmod rewrite headers expires \
    && sed -ri 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf \
    && printf '<Directory /var/www/html/public>\n  AllowOverride All\n  Require all granted\n</Directory>\n' \
       > /etc/apache2/conf-available/typo3.conf \
    && a2enconf typo3

COPY php.ini /usr/local/etc/php/conf.d/zz-typo3.ini
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
