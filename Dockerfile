FROM php:8.2-apache

# Instala extensões necessárias
RUN docker-php-ext-install pdo pdo_mysql

# Habilita .htaccess e reescrita de URL se quiser futuramente
RUN a2enmod rewrite

# Copia configurações personalizadas (opcional)
COPY ./docker/php.ini /usr/local/etc/php/

# Define o diretório raiz do Apache
WORKDIR /var/www/html
