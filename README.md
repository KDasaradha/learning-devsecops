# SimpleFastAPI-Microservices-App

[![CI/CD](https://github.com/your-repo/SimpleFastAPI-Microservices-App/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/your-repo/SimpleFastAPI-Microservices-App/actions/workflows/ci-cd.yml)

A complete DevOps-ready Python microservices project using FastAPI with production-grade tooling including CI/CD, Docker, Docker Swarm, Kubernetes, messaging queues, and API Gateway.

## 🏗️ Architecture

- **Two FastAPI microservices**: `user_service` and `task_service`
- **Notification service**: Kafka consumer for event processing
- **PostgreSQL**: Primary database with connection pooling
- **Kafka + Zookeeper**: Asynchronous messaging between services
- **Kong API Gateway**: Request routing, rate limiting, and CORS
- **Docker Compose**: Local development environment
- **Kubernetes**: Production deployment with health checks
- **GitHub Actions**: CI/CD with automated testing and building

## 📁 Project Structure

```
SimpleFastAPI-Microservices-App/
├── services/
│   ├── user_service/           # User management API
│   │   ├── app/
│   │   │   ├── main.py         # FastAPI app
│   │   │   ├── api.py          # API endpoints
│   │   │   ├── models.py       # SQLAlchemy models
│   │   │   ├── db.py           # Database connection
│   │   │   ├── config.py       # Configuration
│   │   │   └── kafka_producer.py # Kafka integration
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   ├── task_service/           # Task management API
│   │   └── ... (same structure as user_service)
│   └── notification_service/   # Event processing service
│       ├── app/
│       │   ├── main.py         # Kafka consumer
│       │   └── config.py
│       ├── Dockerfile
│       └── requirements.txt
├── shared/
│   └── common_schemas.py       # Shared Pydantic models
├── api_gateway/
│   └── kong/
│       └── kong.yml            # Kong declarative config
├── messaging/
│   └── kafka/
│       └── docker-compose.kafka.yml
├── deployment/
│   ├── docker/
│   │   ├── docker-compose.yml  # Local development
│   │   └── docker-stack.yml    # Docker Swarm
│   └── k8s/
│       └── base/               # Kubernetes manifests
│           ├── namespace.yaml
│           ├── postgresql.yaml
│           ├── kafka.yaml
│           ├── user-service.yaml
│           ├── task-service.yaml
│           ├── notification-service.yaml
│           └── ingress.yaml
├── tests/                      # Test files
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # GitHub Actions workflow
├── .env.example                # Environment variables template
├── Makefile                    # Development commands
└── README.md
```

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- Python 3.11+ (for local development)
- Make (optional, for convenience commands)

### 1. Clone and Setup
```bash
git clone <repository-url>
cd SimpleFastAPI-Microservices-App
cp .env.example .env  # Adjust variables as needed
```

### 2. Start All Services
```bash
# Using Make (recommended)
make dev

# Or directly with Docker Compose
docker compose -f deployment/docker/docker-compose.yml up --build
```

### 3. Access Services
- **Kong API Gateway**: http://localhost:8000
- **Kong Admin**: http://localhost:8444
- **User Service** (direct): http://localhost:8080
- **Task Service** (direct): http://localhost:8081

### 4. API Documentation
- User Service: http://localhost:8080/docs
- Task Service: http://localhost:8081/docs

## 🔗 API Endpoints

### Through Kong Gateway (http://localhost:8000)

#### User Service
```bash
# Create user
curl -X POST http://localhost:8000/users/ \
  -H "Content-Type: application/json" \
  -d '{"username": "john_doe", "email": "john@example.com", "password": "secure123"}'

# List users
curl http://localhost:8000/users/

# Get specific user
curl http://localhost:8000/users/1
```

#### Task Service
```bash
# Create task
curl -X POST http://localhost:8000/tasks/ \
  -H "Content-Type: application/json" \
  -d '{"title": "Complete project", "description": "Finish the microservices project", "user_id": 1}'

# List all tasks
curl http://localhost:8000/tasks/

# Get tasks by user
curl http://localhost:8000/tasks/user/1
```

## 🛠️ Development

### Available Make Commands
```bash
make help              # Show all available commands
make install           # Install dependencies
make lint              # Run code linting
make format            # Format code with black
make test              # Run tests
make dev               # Start development environment
make build             # Build Docker images
make up                # Start services in detached mode
make down              # Stop all services
make logs              # Show logs from all services
make logs-user         # Show user service logs
make logs-task         # Show task service logs
make logs-notification # Show notification service logs
make clean             # Clean up containers and images
make test-api          # Test API endpoints
```

### Local Development Without Docker
```bash
# Install dependencies
make install

# Run individual services
cd services/user_service && uvicorn app.main:app --reload --port 8080
cd services/task_service && uvicorn app.main:app --reload --port 8081
cd services/notification_service && python -m app.main
```

## 🐳 Docker Deployment

### Local Development
```bash
docker compose -f deployment/docker/docker-compose.yml up --build
```

### Docker Swarm
```bash
docker stack deploy -c deployment/docker/docker-stack.yml fastapi-stack
```

## ☸️ Kubernetes Deployment

### Deploy to Kubernetes
```bash
# Create namespace and resources
make k8s-deploy

# Or manually
kubectl apply -f deployment/k8s/base/namespace.yaml
kubectl apply -f deployment/k8s/base/
```

### Check Deployment Status
```bash
kubectl get pods -n fastapi-app
kubectl get services -n fastapi-app
kubectl logs -f deployment/user-service -n fastapi-app
```

### Remove from Kubernetes
```bash
make k8s-delete
```

## 🔧 Configuration

### Environment Variables
Key variables in `.env`:

```bash
# Database
DATABASE_URL=postgresql://user:password@db:5432/dbname

# Services
USER_SERVICE_PORT=8080
TASK_SERVICE_PORT=8081

# Messaging
KAFKA_BROKER=kafka:9092

# API Gateway
KONG_PROXY_PORT=8000
KONG_ADMIN_PORT=8444
```

### Kong Gateway Configuration
The Kong gateway is configured declaratively via `api_gateway/kong/kong.yml`:
- Routes `/users` to user service
- Routes `/tasks` to task service
- Enables rate limiting (100 requests/minute)
- Enables CORS for web clients

## 🧪 Testing

### Run All Tests
```bash
make test
```

### Test Individual Services
```bash
pytest tests/test_user_service.py -v
pytest tests/test_task_service.py -v
```

### Manual API Testing
```bash
make test-api
```

## 📊 Monitoring and Logging

### View Service Logs
```bash
# All services
make logs

# Individual services
make logs-user
make logs-task
make logs-notification
```

### Kafka Topics
```bash
make kafka-topics
```

## 🚀 CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/ci-cd.yml`) includes:

1. **Linting**: Code quality checks with ruff
2. **Testing**: Automated tests with pytest
3. **Building**: Docker image creation for all services
4. **Deployment**: Artifact creation for deployment

### Workflow Triggers
- Push to `main` branch
- Pull requests to `main` branch

## 🏭 Production Considerations

### Security
- API key authentication ready (Kong)
- Environment variable management
- Database connection pooling
- Resource limits in Kubernetes

### Scalability
- Horizontal pod autoscaling ready
- Load balancing via Kong/Kubernetes
- Async messaging with Kafka
- Database connection pooling

### Monitoring
- Health check endpoints
- Structured logging
- Kafka consumer monitoring
- Database connection monitoring

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Run tests: `make test`
4. Run linting: `make lint`
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License.

## 🆘 Troubleshooting

### Common Issues

1. **Port conflicts**: Adjust ports in `.env` file
2. **Database connection**: Ensure PostgreSQL is running
3. **Kafka connectivity**: Check Kafka and Zookeeper status
4. **Docker build fails**: Try `make clean` then `make build`

### Debug Commands
```bash
# Check service status
docker compose ps

# View specific service logs
docker compose logs user_service

# Access service shell
docker compose exec user_service bash

# Check Kafka topics
docker compose exec kafka kafka-topics.sh --bootstrap-server localhost:9092 --list
```

For more help, check the GitHub issues or create a new one.
