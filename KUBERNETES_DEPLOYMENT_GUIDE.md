# Kubernetes Deployment Guide 🚀

## 📋 Prerequisites

- Docker Desktop with Kubernetes enabled
- kubectl installed and configured
- PowerShell (for Windows users)

## 🏗️ Deployment Process

### 1. Run the Deployment Script

```powershell
./deploy-k8s.ps1
```

This script will:
- ✅ Check kubectl availability
- ✅ Test cluster connection
- ✅ Build Docker images for all services
- ✅ Apply Kubernetes manifests
- ✅ Check deployment status

### 2. Verify Deployment Status

```powershell
# Check all resources
kubectl get all -n fastapi-app

# Check pods specifically
kubectl get pods -n fastapi-app

# Watch pods in real-time
kubectl get pods -n fastapi-app -w
```

**Expected Output:**
```
NAME                                    READY   STATUS    RESTARTS   AGE
kafka-0                                 2/2     Running   0          100s
notification-service-545c8466bc-d9rw2   1/1     Running   0          98s
postgresql-b5c697848-vsmdz              1/1     Running   0          100s
task-service-675498988-gd9tn            1/1     Running   1          99s
task-service-675498988-rgd44            1/1     Running   1          99s
user-service-5dfbb4c88b-kjfkr           1/1     Running   1          99s
user-service-5dfbb4c88b-qxvt9           1/1     Running   2          99s
```

## 🌐 Accessing Your Services

### Option 1: Port Forwarding (Recommended for Development)

**Open separate terminal windows for each service:**

```powershell
# User Service (FastAPI docs: http://localhost:8001/docs)
kubectl port-forward service/user-service 8001:8000 -n fastapi-app

# Task Service (FastAPI docs: http://localhost:8002/docs)
kubectl port-forward service/task-service 8002:8000 -n fastapi-app

# Notification Service (FastAPI docs: http://localhost:8003/docs)
kubectl port-forward service/notification-service 8003:80 -n fastapi-app
```

**Access URLs:**
- **User Service**: http://localhost:8001/docs
- **Task Service**: http://localhost:8002/docs  
- **Notification Service**: http://localhost:8003/docs

### Option 2: Service URLs (Internal Cluster Access)
```
- user-service.fastapi-app.svc.cluster.local:8000
- task-service.fastapi-app.svc.cluster.local:8000
- notification-service.fastapi-app.svc.cluster.local:80
```

## 🖥️ Kubernetes Dashboard (Web GUI)

### Setup Dashboard

The dashboard is automatically installed by the deployment script. To access it:

**Step 1: Start Proxy**
```powershell
kubectl proxy
```

**Step 2: Access Dashboard**
Open browser and navigate to:
```
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

**Step 3: Get Access Token**
```powershell
kubectl -n kubernetes-dashboard create token admin-user
```

Copy the generated token and use it to log into the dashboard.

### Dashboard Features
- 📊 **Resource Overview**: View all pods, services, deployments
- 📈 **Monitoring**: CPU, Memory usage graphs
- 📋 **Logs**: View container logs in real-time
- ⚙️ **Configuration**: Edit resources directly
- 🔄 **Scaling**: Scale deployments up/down

## 🛠️ Alternative GUI Tools

### 1. Lens (Desktop Application)
- **Download**: https://k8slens.dev/
- **Features**: Complete Kubernetes IDE
- **Best for**: Production management

### 2. k9s (Terminal UI)
```powershell
# Install via Scoop
scoop install k9s

# Install via Chocolatey
choco install k9s

# Run
k9s
```

### 3. Docker Desktop
- Use the Kubernetes tab in Docker Desktop
- Basic pod and service management

## 📊 Monitoring & Troubleshooting

### Essential Commands

```powershell
# Check pod logs
kubectl logs -f deployment/user-service -n fastapi-app
kubectl logs -f deployment/task-service -n fastapi-app
kubectl logs -f deployment/notification-service -n fastapi-app

# Check pod status with details
kubectl describe pod <pod-name> -n fastapi-app

# Check service endpoints
kubectl get endpoints -n fastapi-app

# Check persistent volumes (for PostgreSQL)
kubectl get pv
kubectl get pvc -n fastapi-app

# Check configmaps and secrets
kubectl get configmaps -n fastapi-app
kubectl get secrets -n fastapi-app
```

### Common Issues & Solutions

**1. Pod in CrashLoopBackOff**
```powershell
kubectl logs <pod-name> -n fastapi-app
kubectl describe pod <pod-name> -n fastapi-app
```

**2. Service Not Accessible**
```powershell
kubectl get services -n fastapi-app
kubectl get endpoints -n fastapi-app
```

**3. Database Connection Issues**
```powershell
kubectl logs deployment/postgresql -n fastapi-app
kubectl exec -it deployment/postgresql -n fastapi-app -- psql -U postgres
```

## ⚙️ Scaling Operations

### Scale Services
```powershell
# Scale user service to 3 replicas
kubectl scale deployment user-service --replicas=3 -n fastapi-app

# Scale task service to 1 replica
kubectl scale deployment task-service --replicas=1 -n fastapi-app

# Check scaling status
kubectl get deployments -n fastapi-app
```

### Auto-scaling (HPA)
```powershell
# Enable auto-scaling based on CPU
kubectl autoscale deployment user-service --cpu-percent=50 --min=1 --max=10 -n fastapi-app

# Check HPA status
kubectl get hpa -n fastapi-app
```

## 🔄 Updates & Rollbacks

### Rolling Updates
```powershell
# Update image
kubectl set image deployment/user-service user-service=user-service:v2 -n fastapi-app

# Check rollout status
kubectl rollout status deployment/user-service -n fastapi-app

# View rollout history
kubectl rollout history deployment/user-service -n fastapi-app
```

### Rollbacks
```powershell
# Rollback to previous version
kubectl rollout undo deployment/user-service -n fastapi-app

# Rollback to specific revision
kubectl rollout undo deployment/user-service --to-revision=2 -n fastapi-app
```

## 🧹 Cleanup

### Remove All Resources
```powershell
# Delete namespace (removes all resources)
kubectl delete namespace fastapi-app

# Delete dashboard
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Delete dashboard admin user
kubectl delete -f dashboard-admin.yaml
```

### Remove Specific Resources
```powershell
# Delete specific deployment
kubectl delete deployment user-service -n fastapi-app

# Delete specific service
kubectl delete service user-service -n fastapi-app
```

## 📚 Useful Resources

- **Kubernetes Documentation**: https://kubernetes.io/docs/
- **kubectl Cheat Sheet**: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- **FastAPI Documentation**: https://fastapi.tiangolo.com/
- **Docker Desktop Kubernetes**: https://docs.docker.com/desktop/kubernetes/

## 🏆 Best Practices

1. **Resource Limits**: Always set CPU/Memory limits
2. **Health Checks**: Implement liveness and readiness probes
3. **Secrets Management**: Use Kubernetes secrets for sensitive data
4. **Namespaces**: Use namespaces to separate environments
5. **Labels**: Use consistent labeling for resource organization
6. **Monitoring**: Set up proper monitoring and alerting
7. **Backups**: Regular backup of persistent data
8. **Security**: Follow Kubernetes security best practices

---

## 🎯 Next Steps After Deployment

1. ✅ **Verify all pods are running**
2. ✅ **Set up port-forwarding for development**
3. ✅ **Access FastAPI documentation endpoints**
4. ✅ **Install and configure Kubernetes Dashboard**
5. ✅ **Test API endpoints**
6. ✅ **Monitor logs for any issues**
7. ✅ **Set up persistent monitoring solution**

Your microservices architecture is now successfully running on Kubernetes! 🎉