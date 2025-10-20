#!/bin/bash
echo "Starting MariaDB setup..."

# Ensure directories and permissions
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld
chmod 755 /run/mysqld
mkdir -p /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
chmod -R 755 /var/lib/mysql
mkdir -p /var/log/mysql
chown mysql:mysql /var/log/mysql
chmod 755 /var/log/mysql

# Force reinitialization
echo "Initializing MariaDB data directory..."
rm -rf /var/lib/mysql/*  # Clear corrupted files
mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db --force --verbose > /var/log/mysql/init.log 2>&1

# Vérification du fichier my.cnf
echo "Checking my.cnf..."
cat /etc/mysql/my.cnf

# Démarrage temporaire de MariaDB pour les scripts d'init
echo "Starting temporary MariaDB for initialization..."
mysqld_safe --skip-networking --skip-syslog --log-error=/var/log/mysql/mariadb.err &
temp_pid=$!

# Attente du socket
for i in {1..30}; do
    if [ -S /run/mysqld/mysqld.sock ]; then
        echo "MariaDB socket found"
        break
    fi
    echo "Waiting for MariaDB socket..."
    sleep 2
done

if [ ! -S /run/mysqld/mysqld.sock ]; then
    echo "Error: MariaDB socket not created. Checking logs..."
    cat /var/log/mysql/init.log
    exit 1
fi

# Exécution des scripts SQL
echo "Running initialization scripts..."
for f in /docker-entrypoint-initdb.d/*; do
    case "$f" in
        *.sql) echo "Running $f"; mysql -u root --socket=/run/mysqld/mysqld.sock < "$f" ;;
        *)     echo "Ignoring $f" ;;
    esac
done

# Arrêt de l'instance temporaire
echo "Stopping temporary MariaDB..."
mysqladmin --socket=/run/mysqld/mysqld.sock shutdown

# Lancer MariaDB en mode normal
echo "MariaDB setup complete, starting MariaDB normally..."
exec mysqld_safe --skip-syslog --log-error=/var/log/mysql/mariadb.err

