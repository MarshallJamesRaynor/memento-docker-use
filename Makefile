export COMPOSE_PROJECT_NAME := mementodockeruse

# Retrieve the Makefile used to manage the Docker environment
COMPOSE_FILE	:= docker-compose.yml

# Project specific variables
PROJECT_PATH := /var/www/html

SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
PHP_SERVICE := docker-compose exec php sh -c

# Define a static project name that will be prepended to each service name
#in the project name dont set '-'
# https://github.com/docker/libnetwork/issues/929#issuecomment-184129857


##
## ----------------------------------------------------------------------------
##   Environment
## ----------------------------------------------------------------------------
##


build: ## Build the environment
	docker-compose build


composer: ## Install Composer dependencies from the "php" container
	$(PHP_SERVICE) "composer install --optimize-autoloader --prefer-dist --working-dir=$(PROJECT_PATH)"


logs: ## Follow logs generated by all containers
	docker-compose logs -f --tail=0

logs-full: ## Follow logs generated by all containers from the containers creation
	docker-compose logs -f

php: ## Open a terminal in the "php" container
	docker-compose exec php sh

ps: ## List all containers managed by the environment
	docker-compose ps


start: ## Start the environment
	docker-compose build
	docker-compose up -d --remove-orphans


stats: ## Print real-time statistics about containers ressources usage
	docker stats $(docker ps --format={{.Names}})


stop: ## Stop the environment
	docker-compose stop


yarn: ## Install npm dependencies from the "php" container
	$(PHP_SERVICE) "yarn install --cwd=$(PROJECT_PATH)"


.PHONY: backup build cache composer logs logs-full nginx php ps restore start stats stop yarn


.DEFAULT_GOAL := help
help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) \
		| sed -e 's/^.*Makefile://g' \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' \
		| sed -e 's/\[32m##/[33m/'