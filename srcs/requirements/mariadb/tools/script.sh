#!/bin/bash

set -e

DB_DIR="/var/lib/mysql"

# Vérifier si la base a déjà été initialisée
if [ ! -d "$DB_DIR/mysql" ]; then
  echo "[INFO] Initialisation de MariaDB..."
  mysql_install_db --user=mysql --ldata=/var/lib/mysql

  echo "[INFO] Lancement temporaire de MariaDB..."
  mysqld --user=mysql --bind-address=0.0.0.0 &

  pid="$!"

  echo "[INFO] Attente de MariaDB..."
  until mariadb-admin ping --silent; do
    sleep 1
  done

  echo "[INFO] Vérification du fichier /init.sql..."
  if [ -f /init.sql ] && [ -s /init.sql ]; then
    echo "[INFO] Exécution du script SQL..."
    mariadb -u root < /init.sql || {
      echo "[ERROR] Failed to execute /init.sql"
      cat /init.sql
      exit 1
    }
  else
    echo "[ERROR] /init.sql does not exist, is empty, or is not a file"
    exit 1
  fi

  echo "[INFO] Arrêt du serveur temporaire..."
  mariadb-admin shutdown
  wait "$pid"
fi

echo "[INFO] Démarrage de MariaDB (mode final)..."
exec mysqld --user=mysql --bind-address=0.0.0.0
