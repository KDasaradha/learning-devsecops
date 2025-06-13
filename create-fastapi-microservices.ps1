# PowerShell script to generate the full folder structure for SimpleFastAPI-Microservices-App

$folders = @(
    "SimpleFastAPI-Microservices-App/services/user_service/app",
    "SimpleFastAPI-Microservices-App/services/task_service/app",
    "SimpleFastAPI-Microservices-App/services/notification_service/app",
    "SimpleFastAPI-Microservices-App/shared",
    "SimpleFastAPI-Microservices-App/api_gateway/kong",
    "SimpleFastAPI-Microservices-App/api_gateway/nginx",
    "SimpleFastAPI-Microservices-App/api_gateway/caddy",
    "SimpleFastAPI-Microservices-App/messaging/kafka",
    "SimpleFastAPI-Microservices-App/messaging/rabbitmq",
    "SimpleFastAPI-Microservices-App/deployment/docker",
    "SimpleFastAPI-Microservices-App/deployment/k8s/base",
    "SimpleFastAPI-Microservices-App/deployment/k8s/helm/charts",
    "SimpleFastAPI-Microservices-App/.github/workflows"
)

$files = @(
    # user_service
    "SimpleFastAPI-Microservices-App/services/user_service/app/main.py",
    "SimpleFastAPI-Microservices-App/services/user_service/app/api.py",
    "SimpleFastAPI-Microservices-App/services/user_service/app/models.py",
    "SimpleFastAPI-Microservices-App/services/user_service/app/db.py",
    "SimpleFastAPI-Microservices-App/services/user_service/app/config.py",
    "SimpleFastAPI-Microservices-App/services/user_service/Dockerfile",
    "SimpleFastAPI-Microservices-App/services/user_service/requirements.txt",
    # task_service
    "SimpleFastAPI-Microservices-App/services/task_service/app/main.py",
    "SimpleFastAPI-Microservices-App/services/task_service/app/api.py",
    "SimpleFastAPI-Microservices-App/services/task_service/app/models.py",
    "SimpleFastAPI-Microservices-App/services/task_service/app/db.py",
    "SimpleFastAPI-Microservices-App/services/task_service/app/config.py",
    "SimpleFastAPI-Microservices-App/services/task_service/Dockerfile",
    "SimpleFastAPI-Microservices-App/services/task_service/requirements.txt",
    # notification_service (optional)
    "SimpleFastAPI-Microservices-App/services/notification_service/app/main.py",
    "SimpleFastAPI-Microservices-App/services/notification_service/app/consumer.py",
    "SimpleFastAPI-Microservices-App/services/notification_service/app/config.py",
    "SimpleFastAPI-Microservices-App/services/notification_service/Dockerfile",
    "SimpleFastAPI-Microservices-App/services/notification_service/requirements.txt",
    # shared
    "SimpleFastAPI-Microservices-App/shared/common_schemas.py",
    # api gateway
    "SimpleFastAPI-Microservices-App/api_gateway/kong/kong.yml",
    "SimpleFastAPI-Microservices-App/api_gateway/nginx/nginx.conf",
    "SimpleFastAPI-Microservices-App/api_gateway/caddy/Caddyfile",
    # messaging
    "SimpleFastAPI-Microservices-App/messaging/kafka/docker-compose.kafka.yml",
    "SimpleFastAPI-Microservices-App/messaging/rabbitmq/docker-compose.rabbitmq.yml",
    # deployment
    "SimpleFastAPI-Microservices-App/deployment/docker/docker-compose.yml",
    "SimpleFastAPI-Microservices-App/deployment/docker/docker-stack.yml",
    "SimpleFastAPI-Microservices-App/deployment/k8s/base/user-service.yaml",
    "SimpleFastAPI-Microservices-App/deployment/k8s/base/task-service.yaml",
    "SimpleFastAPI-Microservices-App/deployment/k8s/base/kafka.yaml",
    "SimpleFastAPI-Microservices-App/deployment/k8s/base/ingress.yaml",
    # .github workflow
    "SimpleFastAPI-Microservices-App/.github/workflows/ci-cd.yml",
    # root files
    "SimpleFastAPI-Microservices-App/.env.example",
    "SimpleFastAPI-Microservices-App/Makefile",
    "SimpleFastAPI-Microservices-App/README.md"
)

# Create folders
foreach ($folder in $folders) {
    if (-Not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
    }
}

# Create files (empty)
foreach ($file in $files) {
    if (-Not (Test-Path $file)) {
        New-Item -ItemType File -Path $file | Out-Null
    }
}

Write-Host "All folders and files have been created!"