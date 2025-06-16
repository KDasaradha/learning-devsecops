# Quick Commands Reference Card 🚀

## 🏗️ Build & Deploy

```bash
# Build all images
docker build -t user-service:latest -f services/user_service/Dockerfile .
docker build -t task-service:latest -f services/task_service/Dockerfile .
docker build -t notification-service:latest -f services/notification_service/Dockerfile .

# Deploy to Kubernetes
./deploy-k8s.ps1
```

## 🔍 Check Status

```bash
# Quick health check
kubectl get pods -n fastapi-app

# Detailed status
kubectl get all -n fastapi-app

# Watch pods in real-time
kubectl get pods -n fastapi-app -w
```

## 🔗 Access Services

```bash
# Port forward (run in separate terminals)
kubectl port-forward service/user-service 8001:8000 -n fastapi-app
kubectl port-forward service/task-service 8002:8000 -n fastapi-app
kubectl port-forward service/notification-service 8003:80 -n fastapi-app

# Access URLs (after port-forwarding)
# http://localhost:8001/docs - User Service
# http://localhost:8002/docs - Task Service  
# http://localhost:8003/docs - Notification Service
```

## 📋 View Logs

```bash
# Service logs
kubectl logs -f deployment/user-service -n fastapi-app
kubectl logs -f deployment/task-service -n fastapi-app
kubectl logs -f deployment/notification-service -n fastapi-app

# Specific pod logs
kubectl logs -f <pod-name> -n fastapi-app
```

## 🛠️ Debug Issues

```bash
# Get failing pods
kubectl get pods -n fastapi-app --field-selector=status.phase!=Running

# Describe problematic pod
kubectl describe pod <pod-name> -n fastapi-app

# Get events
kubectl get events -n fastapi-app --sort-by='.lastTimestamp'

# Execute into pod
kubectl exec -it <pod-name> -n fastapi-app -- bash
```

## 📈 Scale Services

```bash
# Scale up/down
kubectl scale deployment user-service --replicas=3 -n fastapi-app
kubectl scale deployment task-service --replicas=2 -n fastapi-app

# Auto-scaling
kubectl autoscale deployment user-service --cpu-percent=50 --min=1 --max=10 -n fastapi-app
```

## 🔄 Update Services

```bash
# Build new version
docker build -t user-service:v1.1.0 -f services/user_service/Dockerfile .

# Update deployment
kubectl set image deployment/user-service user-service=user-service:v1.1.0 -n fastapi-app

# Check rollout
kubectl rollout status deployment/user-service -n fastapi-app

# Rollback if needed
kubectl rollout undo deployment/user-service -n fastapi-app
```

## 🖥️ Dashboard Access

```bash
# Start proxy
kubectl proxy

# Get admin token
kubectl -n kubernetes-dashboard create token admin-user

# Open browser: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

## 🧹 Cleanup

```bash
# Delete specific pod
kubectl delete pod <pod-name> -n fastapi-app

# Restart deployment
kubectl rollout restart deployment/user-service -n fastapi-app

# Delete entire namespace (removes everything)
kubectl delete namespace fastapi-app
```

## 💾 Docker Local Development

```bash
# Run services locally
docker run -d --name user-service -p 8001:8000 user-service:latest
docker run -d --name task-service -p 8002:8000 task-service:latest
docker run -d --name notification-service -p 8003:80 notification-service:latest

# View local containers
docker ps

# Stop local containers
docker stop user-service task-service notification-service
docker rm user-service task-service notification-service
```

---

## 🆘 Emergency Commands

```bash
# Force delete stuck pod
kubectl delete pod <pod-name> --grace-period=0 --force -n fastapi-app

# Check resource usage
kubectl top pods -n fastapi-app
kubectl top nodes

# Get cluster info
kubectl cluster-info
kubectl get nodes

# Check if cluster is responsive
kubectl get namespaces
```

---

## 📞 One-Liners for Daily Use

```bash
# Check if all services are running
kubectl get pods -n fastapi-app | grep -E "(user-service|task-service|notification-service)" | grep Running

# Get all service URLs (after port-forward)
echo "User: http://localhost:8001/docs"; echo "Task: http://localhost:8002/docs"; echo "Notification: http://localhost:8003/docs"

# Quick restart all services
kubectl rollout restart deployment/user-service deployment/task-service deployment/notification-service -n fastapi-app

# Monitor all pods
watch kubectl get pods -n fastapi-app

# Get pod resource usage
kubectl top pods -n fastapi-app --sort-by=memory

# Count running pods
kubectl get pods -n fastapi-app --field-selector=status.phase=Running --no-headers | wc -l
```

Keep this handy for daily operations! 📌