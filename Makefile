run-user:
	docker compose -f deployment/docker/docker-compose.yml up user_service

run-task:
	docker compose -f deployment/docker/docker-compose.yml up task_service

format:
	black .

lint:
	ruff check .

test:
	pytest