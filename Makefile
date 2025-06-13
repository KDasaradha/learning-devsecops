.PHONY: help install lint test format clean dev build up down logs

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install dependencies for all services
	pip install -r services/user_service/requirements.txt
	pip install -r services/task_service/requirements.txt
	pip install -r services/notification_service/requirements.txt
	pip install ruff pytest black httpx

lint: ## Run linting on all services
	ruff check . --ignore E501

format: ## Format code using black
	black .

test: ## Run all tests
	pytest tests/ -v

clean: ## Clean up Docker containers and images
	docker compose -f deployment/docker/docker-compose.yml down --remove-orphans
	docker system prune -f

dev: ## Start all services for development
	docker compose -f deployment/docker/docker-compose.yml up --build

build: ## Build all Docker images
	docker compose -f deployment/docker/docker-compose.yml build

up: ## Start all services in detached mode
	docker compose -f deployment/docker/docker-compose.yml up -d

down: ## Stop all services
	docker compose -f deployment/docker/docker-compose.yml down

logs: ## Show logs from all services
	docker compose -f deployment/docker/docker-compose.yml logs -f

logs-user: ## Show logs from user service
	docker compose -f deployment/docker/docker-compose.yml logs -f user_service

logs-task: ## Show logs from task service
	docker compose -f deployment/docker/docker-compose.yml logs -f task_service

logs-notification: ## Show logs from notification service
	docker compose -f deployment/docker/docker-compose.yml logs -f notification_service

k8s-deploy: ## Deploy to Kubernetes
	kubectl apply -f deployment/k8s/base/namespace.yaml
	kubectl apply -f deployment/k8s/base/
	
k8s-delete: ## Delete from Kubernetes
	kubectl delete -f deployment/k8s/base/ --ignore-not-found=true

kafka-topics: ## List Kafka topics
	docker compose -f deployment/docker/docker-compose.yml exec kafka kafka-topics.sh --bootstrap-server localhost:9092 --list

test-api: ## Test API endpoints
	@echo "Testing User Service..."
	curl -X POST http://localhost:8000/users/ -H "Content-Type: application/json" -d '{"username":"testuser","email":"test@example.com","password":"testpass"}'
	@echo "\nTesting Task Service..."
	curl -X POST http://localhost:8000/tasks/ -H "Content-Type: application/json" -d '{"title":"Test Task","description":"Test Description","user_id":1}'