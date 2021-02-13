FROM php:7.4-fpm

# Notwendig für gd
RUN apt-get update -y && apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev libzip-dev 

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd

# intl
RUN apt-get install -y libicu-dev
RUN docker-php-ext-install intl

RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pdo_mysql

RUN docker-php-ext-install zip

