FROM debian:bullseye

# Installation des dépendances
RUN apt-get update && apt-get -y install wget php7.4 php7.4-fpm php7.4-mysql mariadb-client

# Création des répertoires nécessaires
RUN mkdir -p /var/www/html /run/php /usr/src/wordpress \
 && chown -R www-data:www-data /var/www/html /run/php /usr/src/wordpress

# Téléchargement et extraction de WordPress
RUN wget https://fr.wordpress.org/wordpress-6.0-fr_FR.tar.gz -P /var/www \
 && tar -xzf /var/www/wordpress-6.0-fr_FR.tar.gz -C /var/www/html --strip-components=1 \
 && rm /var/www/wordpress-6.0-fr_FR.tar.gz \
 && chown -R www-data:www-data /var/www/html \
 && cp -r /var/www/html/* /usr/src/wordpress/ \
 && ls -la /usr/src/wordpress/ # Vérification pour debug

# Installation de WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x wp-cli.phar \
 && mv wp-cli.phar /usr/local/bin/wp

# Configuration de PHP-FPM
RUN echo "clear_env = no" >> /etc/php/7.4/fpm/php.ini \
 && sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = wordpress:9000/g' /etc/php/7.4/fpm/pool.d/www.conf

# Copier le script d'entrée depuis le sous-dossier tools
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Variables d'environnement
ENV WORDPRESS_DB_NAME=wordpress
ENV WORDPRESS_DB_USER=wordpress_user
ENV WORDPRESS_DB_PASSWORD=123
ENV WORDPRESS_DB_HOST=mariadb

# Exposition du port
EXPOSE 9000

# Utilisation du script d'entrée
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm7.4", "-F"]
