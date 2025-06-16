#!/usr/bin/env pwsh
# Kubernetes Setup Script for Windows

Write-Host "🚀 Setting up Kubernetes deployment..." -ForegroundColor Green

# Step 1: Verify Kubernetes is running
Write-Host "`n1️⃣ Checking Kubernetes cluster status..." -ForegroundColor Yellow
kubectl cluster-info
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Kubernetes cluster is not running. Please start Docker Desktop Kubernetes." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Kubernetes cluster is running!" -ForegroundColor Green

# Step 2: Build Docker images for Kubernetes
Write-Host "`n2️⃣ Building Docker images..." -ForegroundColor Yellow

# Build images with Kubernetes-friendly tags
docker build -t user-service:latest -f services/user_service/Dockerfile .
docker build -t task-service:latest -f services/task_service/Dockerfile .
docker build -t notification-service:latest -f services/notification_service/Dockerfile .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build Docker images" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Docker images built successfully!" -ForegroundColor Green

# Step 3: Apply Kubernetes manifests
Write-Host "`n3️⃣ Deploying to Kubernetes..." -ForegroundColor Yellow

# Create namespace
kubectl apply -f deployment/k8s/base/namespace.yaml

# Deploy infrastructure (PostgreSQL, Kafka)
kubectl apply -f deployment/k8s/base/postgresql.yaml
kubectl apply -f deployment/k8s/base/kafka.yaml

# Wait for infrastructure to be ready
Write-Host "⏳ Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgresql -n fastapi-app --timeout=300s

Write-Host "⏳ Waiting for Kafka to be ready..."
kubectl wait --for=condition=ready pod -l app=kafka -n fastapi-app --timeout=300s

# Deploy services
kubectl apply -f deployment/k8s/base/user-service.yaml
kubectl apply -f deployment/k8s/base/task-service.yaml
kubectl apply -f deployment/k8s/base/notification-service.yaml

# Deploy ingress
kubectl apply -f deployment/k8s/base/ingress.yaml

Write-Host "`n4️⃣ Checking deployment status..." -ForegroundColor Yellow
kubectl get pods -n fastapi-app
kubectl get services -n fastapi-app

Write-Host "`n✅ Kubernetes deployment completed!" -ForegroundColor Green
Write-Host "`n📝 Useful commands:" -ForegroundColor Cyan
Write-Host "  • View pods: kubectl get pods -n fastapi-app" -ForegroundColor White
Write-Host "  • View services: kubectl get services -n fastapi-app" -ForegroundColor White
Write-Host "  • View logs: kubectl logs -f deployment/user-service -n fastapi-app" -ForegroundColor White
Write-Host "  • Port forward: kubectl port-forward service/user-service 8001:8000 -n fastapi-app" -ForegroundColor White