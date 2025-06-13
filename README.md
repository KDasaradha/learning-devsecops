# SimpleFastAPI-Microservices-App

A minimal, production-style FastAPI microservices architecture with:

- **FastAPI** microservices (`user_service`, `task_service`)
- **PostgreSQL** database
- **Kafka** (with Zookeeper) for messaging
- **Kong Gateway** (DB-less mode)
- **Docker Compose** for local dev, **Docker Swarm** for prod, **Kubernetes** ready
- **CI/CD** via GitHub Actions

## Project Structure

```
SimpleFastAPI-Microservices-App/
├── services/
│   ├── user_service/
│   ├── task_service/
│   └── notification_service/  # Optional
├── shared/
├── api_gateway/
├── messaging/
├── deployment/
├── .github/
├── .env.example
├── Makefile
└── README.md
```

## Quickstart

1. Copy `.env.example` to `.env` and adjust as needed.
2. Run `docker compose -f deployment/docker/docker-compose.yml up --build`
3. Kong gateway: [http://localhost:8000](http://localhost:8000)
4. Services: [http://localhost:8001/users/](http://localhost:8001/users/), [http://localhost:8002/tasks/](http://localhost:8002/tasks/)

## API Docs

- User: `/docs` at user_service
- Task: `/docs` at task_service

## Development

- `make lint` to lint code
- `make test` to run tests

## CI/CD

- See `.github/workflows/ci-cd.yml`