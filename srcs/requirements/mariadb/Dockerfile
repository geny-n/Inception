FROM debian:bullseye

# Mettre à jour et installer MariaDB et netcat-traditional
RUN apt-get update \
    && apt-get install -y mariadb-server netcat-traditional \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Pour l'écoute via socket Unix (nécessaire par défaut même si on travaille en TCP)
RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

# Copier le script d'init et le script de démarrage
COPY tools/init.sql /docker-entrypoint-initdb.d/
COPY tools/script.sh /script.sh
RUN chmod +x /script.sh

EXPOSE 3306

CMD ["/script.sh"]
