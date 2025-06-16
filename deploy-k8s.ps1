#!/usr/bin/env pwsh
# Simple Kubernetes Deployment Script

Write-Host '🚀 Deploying to Kubernetes...' -ForegroundColor Green

# Check if kubectl is available
if (!(Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host '❌ kubectl not found. Please install kubectl or enable Kubernetes in Docker Desktop.' -ForegroundColor Red
    exit 1
}

# Test cluster connection
Write-Host '📋 Checking Kubernetes cluster...' -ForegroundColor Yellow
kubectl cluster-info --request-timeout=10s
if ($LASTEXITCODE -ne 0) {
    Write-Host '❌ Cannot connect to Kubernetes cluster. Make sure Docker Desktop Kubernetes is running.' -ForegroundColor Red
    exit 1
}

# Build Docker images
Write-Host '`n🏗️ Building Docker images...' -ForegroundColor Yellow
docker build -t user-service:latest -f services/user_service/Dockerfile .
docker build -t task-service:latest -f services/task_service/Dockerfile .
docker build -t notification-service:latest -f services/notification_service/Dockerfile .

# Apply Kubernetes manifests
Write-Host '`n🚀 Applying Kubernetes manifests...' -ForegroundColor Yellow

kubectl apply -f deployment/k8s/base/namespace.yaml
kubectl apply -f deployment/k8s/base/postgresql.yaml
kubectl apply -f deployment/k8s/base/kafka.yaml
kubectl apply -f deployment/k8s/base/user-service.yaml
kubectl apply -f deployment/k8s/base/task-service.yaml
kubectl apply -f deployment/k8s/base/notification-service.yaml

# Check if ingress exists before applying
if (Test-Path 'deployment/k8s/base/ingress.yaml') {
    kubectl apply -f deployment/k8s/base/ingress.yaml
}

Write-Host '`n📊 Checking deployment status...' -ForegroundColor Yellow
kubectl get all -n fastapi-app

# Install Kubernetes Dashboard
Write-Host '`n🖥️ Installing Kubernetes Dashboard...' -ForegroundColor Yellow
$dashboardExists = kubectl get namespace kubernetes-dashboard 2>$null
if ($LASTEXITCODE -ne 0) {
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
    
    # Create admin user for dashboard
    $adminUserYaml = @"
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
"@
    
    $adminUserYaml | kubectl apply -f -
    Write-Host '✅ Dashboard installed successfully' -ForegroundColor Green
} else {
    Write-Host '✅ Dashboard already installed' -ForegroundColor Green
}

Write-Host '`n✅ Deployment completed!' -ForegroundColor Green

# Provide comprehensive next steps
Write-Host '`n📋 Next Steps:' -ForegroundColor Cyan
Write-Host '`n🔗 Access Your Services (Port Forward):' -ForegroundColor Yellow
Write-Host '  kubectl port-forward service/user-service 8001:8000 -n fastapi-app' -ForegroundColor White
Write-Host '  kubectl port-forward service/task-service 8002:8000 -n fastapi-app' -ForegroundColor White
Write-Host '  kubectl port-forward service/notification-service 8003:80 -n fastapi-app' -ForegroundColor White

Write-Host '`n🌐 API Documentation URLs (after port-forwarding):' -ForegroundColor Yellow
Write-Host '  User Service:         http://localhost:8001/docs' -ForegroundColor White
Write-Host '  Task Service:         http://localhost:8002/docs' -ForegroundColor White
Write-Host '  Notification Service: http://localhost:8003/docs' -ForegroundColor White

Write-Host '`n🖥️ Kubernetes Dashboard:' -ForegroundColor Yellow
Write-Host '  1. Run: kubectl proxy' -ForegroundColor White
Write-Host '  2. Open: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/' -ForegroundColor White
Write-Host '  3. Get token: kubectl -n kubernetes-dashboard create token admin-user' -ForegroundColor White

Write-Host '`n🔍 Monitoring Commands:' -ForegroundColor Yellow
Write-Host '  kubectl get pods -n fastapi-app -w' -ForegroundColor White
Write-Host '  kubectl logs -f deployment/user-service -n fastapi-app' -ForegroundColor White
Write-Host '  kubectl logs -f deployment/task-service -n fastapi-app' -ForegroundColor White

Write-Host '`n📚 For complete guide, see: KUBERNETES_DEPLOYMENT_GUIDE.md' -ForegroundColor Cyan