FROM debian:bullseye

# Met à jour les paquets et installe nginx
RUN apt-get update && apt-get install -y nginx && apt-get clean

# Copie la configuration Nginx
COPY conf/default.conf /etc/nginx/conf.d/default.conf

#installer openssl
RUN apt-get update && apt-get install -y nginx openssl && apt-get clean

#Crée un nouveau certificat SSL/TLS pour ton serveur.
#Crée une clé privée associée.
#Met les fichiers générés dans /etc/nginx/certs/
RUN mkdir -p /etc/nginx/certs && \
    openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout /etc/nginx/certs/privkey.pem \
    -out /etc/nginx/certs/fullchain.pem \
    -days 365 \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/CN=${MY_DOMAIN_NAME}/UID=ngeny"

# /usr/share/nginx/html/ est configuré comme la racine du serveur web par défaut.
#COPY index.html /usr/share/nginx/html/

# Expose le port 443
EXPOSE 443

# Lance nginx en avant-plan
CMD ["nginx", "-g", "daemon off;"]
