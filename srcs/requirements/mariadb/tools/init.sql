-- Mot de passe root (important pour la gestion sécurisée)
ALTER USER 'root'@'localhost' IDENTIFIED BY '123';
FLUSH PRIVILEGES;

-- Création de la base WordPress attendue
CREATE DATABASE IF NOT EXISTS wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Création de l'utilisateur WordPress et droits (connexion via le docker donc externe)
CREATE USER IF NOT EXISTS 'wordpress_user'@'%' IDENTIFIED BY '123';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress_user'@'%';

-- Création de l'utilisateur Mariadb et droits (connexion en interne dans le container)
CREATE USER IF NOT EXISTS 'wordpress_user'@'localhost' IDENTIFIED BY '123';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress_user'@'localhost';

FLUSH PRIVILEGES;

