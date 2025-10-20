#!/bin/bash

# Vérifier si /var/www/html contient les fichiers WordPress
echo "Checking contents of /var/www/html before copy..."
ls -la /var/www/html/ || echo "Error: Unable to list /var/www/html"
echo "Checking contents of /usr/src/wordpress..."
ls -la /usr/src/wordpress/ || echo "Error: /usr/src/wordpress is empty or does not exist"

# Copier les fichiers WordPress depuis /usr/src/wordpress si /var/www/html est vide ou manque de fichiers clés
if [ ! -f /var/www/html/wp-settings.php ]; then
  echo "WordPress files not found in /var/www/html, copying files..."
  cp -rv /usr/src/wordpress/* /var/www/html/ || echo "Error: Failed to copy files from /usr/src/wordpress to /var/www/html"
  chown -R www-data:www-data /var/www/html
  chmod -R 755 /var/www/html
else
  echo "WordPress files already exist in /var/www/html, skipping copy."
fi

# Vérifier le contenu de /var/www/html après copie
echo "Checking contents of /var/www/html after copy..."
ls -la /var/www/html/ || echo "Error: /var/www/html is empty after copy"

# Attendre que MariaDB soit prêt avec un délai maximal
echo "Waiting for MariaDB to be ready..."
timeout=120
elapsed=0
until mysql -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "SELECT 1" "$WORDPRESS_DB_NAME" 2>/dev/null; do
  echo "MariaDB not ready yet, waiting... (elapsed: $elapsed seconds)"
  sleep 2
  elapsed=$((elapsed + 2))
  if [ $elapsed -ge $timeout ]; then
    echo "Error: Timeout waiting for MariaDB after $timeout seconds"
    break
  fi
done

if [ $elapsed -lt $timeout ]; then
  echo "MariaDB is ready!"
else
  echo "Warning: MariaDB connection failed, proceeding anyway."
fi

# Créer wp-config.php si nécessaire
if [ ! -f /var/www/html/wp-config.php ]; then
  echo "Creating wp-config.php..."
  if [ $elapsed -lt $timeout ]; then
    # Essayer de créer wp-config.php avec WP-CLI
    wp config create --allow-root \
      --dbname="$WORDPRESS_DB_NAME" \
      --dbuser="$WORDPRESS_DB_USER" \
      --dbpass="$WORDPRESS_DB_PASSWORD" \
      --dbhost="$WORDPRESS_DB_HOST" \
      --path=/var/www/html || {
        echo "Error: Failed to create wp-config.php with WP-CLI: $?"
        exit 1
      }
  else
    echo "MariaDB not available, creating fallback wp-config.php..."
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
    sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
    sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
    sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php
  fi
fi

# Vérifier si WordPress est installé, sinon l'installer
if ! wp core is-installed --allow-root --path=/var/www/html 2>/dev/null; then
  echo "WordPress is not installed, running wp core install..."
  wp core install \
    --url=https://ngeny.42.fr \
    --title="Mon Site WordPress" \
    --admin_user=caramel \
    --admin_password=123 \
    --admin_email=caramel@ngeny.42.fr \
    --allow-root \
    --path=/var/www/html || {
      echo "Error: Failed to install WordPress: $?"
      exit 1
    }
  echo "WordPress installed successfully!"
  
# Ajouter un utilisateur contributeur
  wp user create \
    pokemon pokemon@example.com \
    --role=contributor \
    --user_pass=123 \
    --allow-root \
    --path=/var/www/html

  # Configurer la page d'accueil comme une page statique (optionnel)
  wp post create --post_type=page --post_title="Accueil" --post_status=publish --allow-root --path=/var/www/html
  wp option update show_on_front page --allow-root --path=/var/www/html
  wp option update page_on_front "$(wp post list --post_type=page --post_status=publish --posts_per_page=1 --field=ID --allow-root --path=/var/www/html)" --allow-root --path=/var/www/html
fi

# Définir le propriétaire et les permissions sécurisées pour wp-config.php
if [ -f /var/www/html/wp-config.php ]; then
  echo "Setting secure permissions and owner for wp-config.php..."
  chown www-data:www-data /var/www/html/wp-config.php
  chmod 600 /var/www/html/wp-config.php
else
  echo "wp-config.php not found, skipping permission and owner change."
fi

# Exécuter la commande passée (par défaut php-fpm7.4 -F)
exec "$@"
