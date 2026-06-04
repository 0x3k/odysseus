# Odysseus -- NVIDIA GPU Docker Compose helper
#
# Every target composes the base file WITH the NVIDIA GPU overlay so the
# odysseus container is granted GPU access
# (deploy.resources.reservations.devices + NVIDIA_* env from docker/gpu.nvidia.yml).
#
# For an AMD GPU host, swap the overlay to docker/gpu.amd.yml below.

COMPOSE := docker compose -f docker-compose.yml -f docker/gpu.nvidia.yml
SERVICE := odysseus

.DEFAULT_GOAL := help
.PHONY: help build up start down stop restart recreate logs logs-all ps status shell gpu-check pull config

help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-11s\033[0m %s\n", $$1, $$2}'

build: ## Build images with the GPU overlay
	$(COMPOSE) build

up: ## Build (if needed) and start the full stack in the background
	$(COMPOSE) up -d

start: up ## Alias for `up`

down: ## Stop and remove containers (keeps named volumes)
	$(COMPOSE) down

stop: ## Stop containers without removing them
	$(COMPOSE) stop

restart: ## Restart the stack
	$(COMPOSE) restart

recreate: ## Force rebuild + recreate all containers
	$(COMPOSE) up -d --build --force-recreate

logs: ## Follow logs for the odysseus service
	$(COMPOSE) logs -f $(SERVICE)

logs-all: ## Follow logs for every service
	$(COMPOSE) logs -f

ps: ## Show container status
	$(COMPOSE) ps

status: ps ## Alias for `ps`

shell: ## Open a bash shell inside the odysseus container
	$(COMPOSE) exec $(SERVICE) bash

gpu-check: ## Verify the odysseus container can see the GPU
	$(COMPOSE) exec $(SERVICE) nvidia-smi

pull: ## Pull updated base images
	$(COMPOSE) pull

config: ## Render the merged compose config (debug)
	$(COMPOSE) config
