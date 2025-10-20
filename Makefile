DOCKER_COMPOSE = docker-compose
ENV_FILE = ./srcs/.env
COMPOSE_FILE = ./srcs/docker-compose.yml

# Applique les bonnes permissions avant build
make all :  build up
#chmod_script:
#	chmod 755 ./srcs/requirements/mariadb/tools/script.sh
#	chmod 755 ./srcs/requirements/wordpress/tools/script.sh
	
build:
	mkdir -p /home/ngeny/data/wordpress
	mkdir -p /home/ngeny/data/mariadb
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) --env-file $(ENV_FILE) build

up:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up -d

down:
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down
	
clean:
	# Arrêter et supprimer les conteneurs, réseaux et volumes du projet
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down --volumes --remove-orphans

	# Supprimer les images construites par docker-compose (basé sur le projet)
	# docker images --filter=label=com.docker.compose.project=srcs -q | sort -u | xargs -r docker rmi -f || true
	docker rmi -f $$(docker images -q | sort -u)	

clean_all:
# Arrêter et supprimer les conteneurs, réseaux et volumes du projet
	$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down --volumes --remove-orphans

# Supprimer les images construites par docker-compose (basé sur le projet)
	docker images --filter=label=com.docker.compose.project=srcs -q | sort -u | xargs -r docker rmi -f || true
	docker rmi -f $$(docker images -q | sort -u)

# Nettoyer les dossiers de données MariaDB et WordPress sur l’hôte
	sudo rm -rf /home/ngeny/data/mariadb/* || true
	sudo rm -rf /home/ngeny/data/wordpress/* || true
	sudo rm -rf /home/ngeny/data/ || true

