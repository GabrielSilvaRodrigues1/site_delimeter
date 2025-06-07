FROM php:8.2-apache

# Instala extensões necessárias
RUN docker-php-ext-install pdo pdo_mysql

# Instala o Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copia os arquivos do projeto para o container
COPY ./public /var/www/html
COPY ./src /var/www/html/src
COPY ./database /var/www/html/database

# Permite .htaccess e reescrita de URL
RUN a2enmod rewrite
RUN chown -R www-data:www-data /var/www/html

# Define o diretório de trabalho
WORKDIR /var/www/html

# Copia o php.ini customizado
COPY ./docker/php.ini /usr/local/etc/php/php.ini

# Instala dependências do Composer (se houver)
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

EXPOSE 80