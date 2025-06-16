#!/usr/bin/env pwsh
# Enhanced Kubernetes Deployment Script
# This script deploys the FastAPI microservices architecture to Kubernetes

param(
    [switch]$SkipDashboard,
    [switch]$WaitForReady,
    [int]$TimeoutMinutes = 5
)

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

# Check if Docker is running
Write-Host '🐳 Checking Docker...' -ForegroundColor Yellow
try {
    docker version --format '{{.Server.Version}}' | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not responding"
    }
    Write-Host '✅ Docker is running' -ForegroundColor Green
} catch {
    Write-Host '❌ Docker is not running. Please start Docker Desktop.' -ForegroundColor Red
    exit 1
}

# Build Docker images
Write-Host "`n🏗️ Building Docker images..." -ForegroundColor Yellow
$images = @(
    @{name="user-service"; dockerfile="services/user_service/Dockerfile"},
    @{name="task-service"; dockerfile="services/task_service/Dockerfile"},
    @{name="notification-service"; dockerfile="services/notification_service/Dockerfile"}
)

foreach ($image in $images) {
    Write-Host "Building $($image.name):latest..." -ForegroundColor Cyan
    docker build -t "$($image.name):latest" -f $image.dockerfile .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to build $($image.name)" -ForegroundColor Red
        exit 1
    }
}

# Apply Kubernetes manifests
Write-Host "`n🚀 Applying Kubernetes manifests..." -ForegroundColor Yellow

$manifests = @(
    'deployment/k8s/base/namespace.yaml',
    'deployment/k8s/base/postgresql.yaml',
    'deployment/k8s/base/kafka.yaml',
    'deployment/k8s/base/user-service.yaml',
    'deployment/k8s/base/task-service.yaml',
    'deployment/k8s/base/notification-service.yaml'
)

foreach ($manifest in $manifests) {
    if (Test-Path $manifest) {
        Write-Host "Applying $manifest..." -ForegroundColor Cyan
        kubectl apply -f $manifest
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Failed to apply $manifest" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "⚠️ Manifest not found: $manifest" -ForegroundColor Yellow
    }
}

# Check if ingress exists before applying
if (Test-Path 'deployment/k8s/base/ingress.yaml') {
    Write-Host "Applying ingress.yaml..." -ForegroundColor Cyan
    kubectl apply -f deployment/k8s/base/ingress.yaml
}

# Wait for pods to be ready if requested
if ($WaitForReady) {
    Write-Host "`n⏳ Waiting for pods to be ready (timeout: $TimeoutMinutes minutes)..." -ForegroundColor Yellow
    
    $deployments = @('postgresql', 'user-service', 'task-service', 'notification-service')
    $statefulsets = @('kafka')
    
    foreach ($deployment in $deployments) {
        Write-Host "Waiting for deployment/$deployment..." -ForegroundColor Cyan
        kubectl wait --for=condition=available --timeout="${TimeoutMinutes}m" deployment/$deployment -n fastapi-app
        if ($LASTEXITCODE -ne 0) {
            Write-Host "⚠️ Timeout waiting for deployment/$deployment" -ForegroundColor Yellow
        }
    }
    
    foreach ($statefulset in $statefulsets) {
        Write-Host "Waiting for statefulset/$statefulset..." -ForegroundColor Cyan
        kubectl wait --for=condition=ready --timeout="${TimeoutMinutes}m" pod -l app=$statefulset -n fastapi-app
        if ($LASTEXITCODE -ne 0) {
            Write-Host "⚠️ Timeout waiting for statefulset/$statefulset" -ForegroundColor Yellow
        }
    }
}

# Install Kubernetes Dashboard (unless skipped)
if (-not $SkipDashboard) {
    Write-Host "`n🖥️ Installing Kubernetes Dashboard..." -ForegroundColor Yellow
    
    # Check if dashboard is already installed
    $dashboardExists = kubectl get namespace kubernetes-dashboard 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Installing Dashboard..." -ForegroundColor Cyan
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
        
        # Create admin user
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
        
        Write-Host "✅ Dashboard installed successfully" -ForegroundColor Green
    } else {
        Write-Host "✅ Dashboard already installed" -ForegroundColor Green
    }
}

# Check deployment status
Write-Host "`n📊 Checking deployment status..." -ForegroundColor Yellow
kubectl get all -n fastapi-app

# Check pod status specifically
Write-Host "`n🔍 Pod Status:" -ForegroundColor Yellow
kubectl get pods -n fastapi-app -o wide

Write-Host "`n✅ Deployment completed!" -ForegroundColor Green

# Provide comprehensive next steps
Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
Write-Host "`n🔗 Access Your Services (Port Forward):" -ForegroundColor Yellow
Write-Host "  kubectl port-forward service/user-service 8001:8000 -n fastapi-app" -ForegroundColor White
Write-Host "  kubectl port-forward service/task-service 8002:8000 -n fastapi-app" -ForegroundColor White
Write-Host "  kubectl port-forward service/notification-service 8003:80 -n fastapi-app" -ForegroundColor White

Write-Host "`n🌐 API Documentation URLs (after port-forwarding):" -ForegroundColor Yellow
Write-Host "  User Service:         http://localhost:8001/docs" -ForegroundColor White
Write-Host "  Task Service:         http://localhost:8002/docs" -ForegroundColor White
Write-Host "  Notification Service: http://localhost:8003/docs" -ForegroundColor White

if (-not $SkipDashboard) {
    Write-Host "`n🖥️ Kubernetes Dashboard:" -ForegroundColor Yellow
    Write-Host "  1. Run: kubectl proxy" -ForegroundColor White
    Write-Host "  2. Open: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/" -ForegroundColor White
    Write-Host "  3. Get token: kubectl -n kubernetes-dashboard create token admin-user" -ForegroundColor White
}

Write-Host "`n🔍 Monitoring Commands:" -ForegroundColor Yellow
Write-Host "  kubectl get pods -n fastapi-app -w" -ForegroundColor White
Write-Host "  kubectl logs -f deployment/user-service -n fastapi-app" -ForegroundColor White
Write-Host "  kubectl logs -f deployment/task-service -n fastapi-app" -ForegroundColor White
Write-Host "  kubectl logs -f deployment/notification-service -n fastapi-app" -ForegroundColor White

Write-Host "`n📚 For complete guide, see: KUBERNETES_DEPLOYMENT_GUIDE.md" -ForegroundColor Cyan

# Final health check
Write-Host "`n🏥 Quick Health Check:" -ForegroundColor Yellow
$notReadyPods = kubectl get pods -n fastapi-app --field-selector=status.phase!=Running --no-headers 2>$null
if ($notReadyPods) {
    Write-Host "⚠️ Some pods are not ready yet. Check their status:" -ForegroundColor Yellow
    Write-Host $notReadyPods -ForegroundColor White
    Write-Host "Run with -WaitForReady flag to wait for all pods to be ready" -ForegroundColor Cyan
} else {
    Write-Host "✅ All pods are running!" -ForegroundColor Green
}

Write-Host "`n🎉 Happy coding!" -ForegroundColor Magenta