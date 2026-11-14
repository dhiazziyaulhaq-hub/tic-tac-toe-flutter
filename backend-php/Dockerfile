
FROM php:8.2-apache

# Mengaktifkan ekstensi PDO MySQL
RUN docker-php-ext-install pdo pdo_mysql

# Mengaktifkan Apache mod_rewrite
RUN a2enmod rewrite

# Mengatur direktori kerja
WORKDIR /var/www/html

# Menginstal Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Mengatur permission direktori
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
