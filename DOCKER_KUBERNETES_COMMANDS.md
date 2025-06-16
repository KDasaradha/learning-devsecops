# Docker & Kubernetes Commands Reference 🐳☸️

## 🐳 Docker Commands

### Building Images

```bash
# Build all services
docker build -t user-service:latest -f services/user_service/Dockerfile .
docker build -t task-service:latest -f services/task_service/Dockerfile .
docker build -t notification-service:latest -f services/notification_service/Dockerfile .

# Build with specific tags
docker build -t user-service:v1.0.0 -f services/user_service/Dockerfile .
docker build -t task-service:v1.0.0 -f services/task_service/Dockerfile .
docker build -t notification-service:v1.0.0 -f services/notification_service/Dockerfile .

# Build without cache
docker build --no-cache -t user-service:latest -f services/user_service/Dockerfile .

# Build with build arguments
docker build --build-arg ENV=production -t user-service:latest -f services/user_service/Dockerfile .
```

### Running Containers Locally

```bash
# Run user service
docker run -d --name user-service \
  -p 8001:8000 \
  -e DATABASE_URL=postgresql://postgres:password@host.docker.internal:5432/userdb \
  user-service:latest

# Run task service
docker run -d --name task-service \
  -p 8002:8000 \
  -e DATABASE_URL=postgresql://postgres:password@host.docker.internal:5432/taskdb \
  -e KAFKA_BOOTSTRAP_SERVERS=host.docker.internal:9092 \
  task-service:latest

# Run notification service
docker run -d --name notification-service \
  -p 8003:80 \
  -e KAFKA_BOOTSTRAP_SERVERS=host.docker.internal:9092 \
  notification-service:latest

# Run with environment file
docker run -d --name user-service \
  -p 8001:8000 \
  --env-file .env \
  user-service:latest
```

### Docker Compose Commands

```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d user-service

# Build and start
docker-compose up -d --build

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# View logs
docker-compose logs -f user-service
docker-compose logs -f --tail=100 task-service

# Scale services
docker-compose up -d --scale user-service=3
docker-compose up -d --scale task-service=2

# Restart service
docker-compose restart user-service

# Execute commands in running container
docker-compose exec user-service bash
docker-compose exec postgresql psql -U postgres
```

### Image Management

```bash
# List images
docker images

# Remove image
docker rmi user-service:latest

# Remove unused images
docker image prune

# Tag image for registry
docker tag user-service:latest myregistry/user-service:latest

# Push to registry
docker push myregistry/user-service:latest

# Pull from registry
docker pull myregistry/user-service:latest

# Save image to file
docker save user-service:latest > user-service.tar

# Load image from file
docker load < user-service.tar
```

### Container Management

```bash
# List running containers
docker ps

# List all containers
docker ps -a

# Stop container
docker stop user-service

# Remove container
docker rm user-service

# Remove all stopped containers
docker container prune

# View container logs
docker logs -f user-service
docker logs --tail=100 user-service

# Execute command in container
docker exec -it user-service bash
docker exec -it user-service python manage.py shell

# Copy files to/from container
docker cp file.txt user-service:/app/
docker cp user-service:/app/logs.txt ./logs.txt

# View container resource usage
docker stats
docker stats user-service

# Inspect container
docker inspect user-service
```

---

## ☸️ Kubernetes Commands

### Cluster Management

```bash
# Check cluster info
kubectl cluster-info

# Get cluster status
kubectl get nodes

# Check cluster version
kubectl version

# View cluster events
kubectl get events --sort-by='.lastTimestamp'

# Get cluster config
kubectl config view

# Switch context
kubectl config use-context docker-desktop
```

### Namespace Management

```bash
# Create namespace
kubectl create namespace fastapi-app

# List namespaces
kubectl get namespaces

# Set default namespace
kubectl config set-context --current --namespace=fastapi-app

# Delete namespace (removes all resources)
kubectl delete namespace fastapi-app
```

### Deployment Management

```bash
# Apply manifests
kubectl apply -f deployment/k8s/base/

# Apply specific manifest
kubectl apply -f deployment/k8s/base/user-service.yaml

# Get deployments
kubectl get deployments -n fastapi-app

# Describe deployment
kubectl describe deployment user-service -n fastapi-app

# Delete deployment
kubectl delete deployment user-service -n fastapi-app

# Scale deployment
kubectl scale deployment user-service --replicas=3 -n fastapi-app

# Get deployment status
kubectl rollout status deployment/user-service -n fastapi-app

# View deployment history
kubectl rollout history deployment/user-service -n fastapi-app

# Rollback deployment
kubectl rollout undo deployment/user-service -n fastapi-app

# Rollback to specific revision
kubectl rollout undo deployment/user-service --to-revision=2 -n fastapi-app

# Restart deployment
kubectl rollout restart deployment/user-service -n fastapi-app
```

### Pod Management

```bash
# Get pods
kubectl get pods -n fastapi-app

# Get pods with details
kubectl get pods -n fastapi-app -o wide

# Watch pods
kubectl get pods -n fastapi-app -w

# Describe pod
kubectl describe pod <pod-name> -n fastapi-app

# Get pod logs
kubectl logs <pod-name> -n fastapi-app

# Follow logs
kubectl logs -f <pod-name> -n fastapi-app

# Get logs from specific container
kubectl logs <pod-name> -c <container-name> -n fastapi-app

# Get previous logs (from crashed container)
kubectl logs <pod-name> --previous -n fastapi-app

# Execute command in pod
kubectl exec -it <pod-name> -n fastapi-app -- bash

# Execute command in specific container
kubectl exec -it <pod-name> -c <container-name> -n fastapi-app -- bash

# Copy files to/from pod
kubectl cp file.txt fastapi-app/<pod-name>:/app/
kubectl cp fastapi-app/<pod-name>:/app/logs.txt ./logs.txt

# Delete pod
kubectl delete pod <pod-name> -n fastapi-app

# Get pods by label
kubectl get pods -l app=user-service -n fastapi-app

# Get pod resource usage
kubectl top pods -n fastapi-app
```

### Service Management

```bash
# Get services
kubectl get services -n fastapi-app

# Describe service
kubectl describe service user-service -n fastapi-app

# Delete service
kubectl delete service user-service -n fastapi-app

# Get service endpoints
kubectl get endpoints -n fastapi-app

# Port forward to service
kubectl port-forward service/user-service 8001:8000 -n fastapi-app

# Port forward to pod
kubectl port-forward pod/<pod-name> 8001:8000 -n fastapi-app

# Expose deployment as service
kubectl expose deployment user-service --type=ClusterIP --port=8000 -n fastapi-app
```

### ConfigMap and Secret Management

```bash
# Create configmap from file
kubectl create configmap app-config --from-file=config.yaml -n fastapi-app

# Create configmap from literal
kubectl create configmap app-config --from-literal=database_host=postgresql -n fastapi-app

# Get configmaps
kubectl get configmaps -n fastapi-app

# Describe configmap
kubectl describe configmap app-config -n fastapi-app

# Create secret
kubectl create secret generic db-secret \
  --from-literal=username=postgres \
  --from-literal=password=password \
  -n fastapi-app

# Create secret from file
kubectl create secret generic tls-secret \
  --from-file=tls.crt=server.crt \
  --from-file=tls.key=server.key \
  -n fastapi-app

# Get secrets
kubectl get secrets -n fastapi-app

# Describe secret
kubectl describe secret db-secret -n fastapi-app

# Delete configmap/secret
kubectl delete configmap app-config -n fastapi-app
kubectl delete secret db-secret -n fastapi-app
```

### Persistent Volume Management

```bash
# Get persistent volumes
kubectl get pv

# Get persistent volume claims
kubectl get pvc -n fastapi-app

# Describe PVC
kubectl describe pvc postgresql-pvc -n fastapi-app

# Delete PVC
kubectl delete pvc postgresql-pvc -n fastapi-app
```

### Ingress Management

```bash
# Get ingress
kubectl get ingress -n fastapi-app

# Describe ingress
kubectl describe ingress api-ingress -n fastapi-app

# Delete ingress
kubectl delete ingress api-ingress -n fastapi-app
```

### Monitoring and Debugging

```bash
# Get all resources
kubectl get all -n fastapi-app

# Get events
kubectl get events -n fastapi-app --sort-by='.lastTimestamp'

# Watch events
kubectl get events -n fastapi-app --watch

# Get pod resource usage
kubectl top pods -n fastapi-app

# Get node resource usage
kubectl top nodes

# Debug pod
kubectl debug <pod-name> -n fastapi-app --image=busybox

# Run temporary pod for debugging
kubectl run debug --image=busybox --rm -it --restart=Never -n fastapi-app -- sh

# Check pod ready conditions
kubectl get pods -n fastapi-app -o custom-columns=NAME:.metadata.name,READY:.status.conditions[?(@.type==\"Ready\")].status

# Get pods not ready
kubectl get pods -n fastapi-app --field-selector=status.phase!=Running
```

### Auto-scaling

```bash
# Create horizontal pod autoscaler
kubectl autoscale deployment user-service --cpu-percent=50 --min=1 --max=10 -n fastapi-app

# Get HPA
kubectl get hpa -n fastapi-app

# Describe HPA
kubectl describe hpa user-service -n fastapi-app

# Delete HPA
kubectl delete hpa user-service -n fastapi-app

# Create VPA (Vertical Pod Autoscaler)
kubectl apply -f - <<EOF
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: user-service-vpa
  namespace: fastapi-app
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: user-service
  updatePolicy:
    updateMode: "Off"
EOF
```

### Resource Management

```bash
# Apply resource quotas
kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: fastapi-app-quota
  namespace: fastapi-app
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "10"
EOF

# Get resource quotas
kubectl get resourcequota -n fastapi-app

# Apply limit ranges
kubectl apply -f - <<EOF
apiVersion: v1
kind: LimitRange
metadata:
  name: fastapi-app-limits
  namespace: fastapi-app
spec:
  limits:
  - default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    type: Container
EOF

# Get limit ranges
kubectl get limitranges -n fastapi-app
```

### Backup and Restore

```bash
# Backup namespace resources
kubectl get all,configmaps,secrets,pvc -n fastapi-app -o yaml > backup-fastapi-app.yaml

# Restore from backup
kubectl apply -f backup-fastapi-app.yaml

# Export single resource
kubectl get deployment user-service -n fastapi-app -o yaml > user-service-backup.yaml

# Create backup of etcd (cluster admin required)
kubectl get secrets -n kube-system | grep etcd
```

---

## 🔧 Useful Combined Commands

### Development Workflow

```bash
# Build, tag, and deploy
docker build -t user-service:v1.1.0 -f services/user_service/Dockerfile .
kubectl set image deployment/user-service user-service=user-service:v1.1.0 -n fastapi-app
kubectl rollout status deployment/user-service -n fastapi-app

# Quick restart all services
kubectl rollout restart deployment/user-service -n fastapi-app
kubectl rollout restart deployment/task-service -n fastapi-app
kubectl rollout restart deployment/notification-service -n fastapi-app

# Check all service health
kubectl get pods -n fastapi-app | grep -E "(user-service|task-service|notification-service)"
```

### Debugging Workflow

```bash
# Get failing pods
kubectl get pods -n fastapi-app --field-selector=status.phase!=Running

# Check pod logs for errors
kubectl logs -f deployment/user-service -n fastapi-app | grep -i error

# Debug network connectivity
kubectl run netshoot --image=nicolaka/netshoot --rm -it --restart=Never -n fastapi-app
# Inside netshoot container: ping user-service, nslookup user-service, etc.

# Check service endpoints
kubectl get endpoints -n fastapi-app
kubectl describe endpoints user-service -n fastapi-app
```

### Performance Monitoring

```bash
# Monitor resource usage
watch kubectl top pods -n fastapi-app

# Check pod restart counts
kubectl get pods -n fastapi-app --sort-by='.status.containerStatuses[0].restartCount'

# Get pod age
kubectl get pods -n fastapi-app --sort-by=.metadata.creationTimestamp
```

### Cleanup Commands

```bash
# Clean up completed jobs
kubectl delete jobs --field-selector status.successful=1 -n fastapi-app

# Clean up evicted pods
kubectl get pods -n fastapi-app --field-selector=status.phase=Failed -o name | xargs kubectl delete -n fastapi-app

# Force delete stuck pods
kubectl delete pod <pod-name> --grace-period=0 --force -n fastapi-app

# Clean up unused config maps and secrets
kubectl get configmaps -n fastapi-app --no-headers | awk '{print $1}' | xargs -I {} sh -c 'kubectl get pods -n fastapi-app -o yaml | grep -q {} || echo "ConfigMap {} is not used"'
```

---

## 📚 Quick Reference Scripts

### Create a monitoring script

```bash
#!/bin/bash
# monitor.sh
echo "🔍 FastAPI App Status"
echo "===================="
echo "Pods:"
kubectl get pods -n fastapi-app
echo -e "\nServices:"
kubectl get services -n fastapi-app
echo -e "\nResource Usage:"
kubectl top pods -n fastapi-app 2>/dev/null || echo "Metrics server not available"
```

### Create a logs script

```bash
#!/bin/bash
# logs.sh
SERVICE=${1:-user-service}
echo "📋 Logs for $SERVICE"
echo "==================="
kubectl logs -f deployment/$SERVICE -n fastapi-app --tail=100
```

### Create a port-forward script

```bash
#!/bin/bash
# port-forward.sh
echo "🔗 Starting port forwards..."
kubectl port-forward service/user-service 8001:8000 -n fastapi-app &
kubectl port-forward service/task-service 8002:8000 -n fastapi-app &
kubectl port-forward service/notification-service 8003:80 -n fastapi-app &
echo "✅ Port forwards started. Press Ctrl+C to stop all."
wait
```

---

## 🖥️ Kubernetes Dashboard Access

### Quick Dashboard Setup

```bash
# 1. Start proxy (run in a separate terminal)
kubectl proxy

# 2. Generate access token
kubectl -n kubernetes-dashboard create token admin-user

# 3. Open browser and navigate to:
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

# 4. Use the token from step 2 to login
```

### Current Access Token
```
eyJhbGciOiJSUzI1NiIsImtpZCI6IjFaTWJYWDFZQmVyTzR4dGsxeDZTR0lCVENlTm03Q01jM2NJZklUbFhmd2sifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzQ5ODI0MDc5LCJpYXQiOjE3NDk4MjA0NzksImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiOWEwMzY1NjMtYjU3Ny00NjM5LTlkZTUtZGVkMzg2ZDEzOWRhIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJhZG1pbi11c2VyIiwidWlkIjoiYWI5OWVkNzItYWRmNS00Mzk3LThkOWYtMDU1ZTRlOTc1MDNkIn19LCJuYmYiOjE3NDk4MjA0NzksInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDphZG1pbi11c2VyIn0.wTbAnz9jsicZGtvksavjdiCPIS289izqxzg-TE_lK8tE3nyGT4sUhovp_GFG_72FMF1EzXsb2ju5PlFDxpVICigPdtoPKEn3MwkgE7cEi70AU_AhM5SCQLfrIcjbpJbFRK5z1Is50mLmkx4TTHpudEcz-IlninaEcTNNfC3ZPcuRFjwEjjWUdlpzx-OMm80bjbTNGvjqPZ1VLcKegxSzy1yoPYYPbZxxGSM3sXqFTnfNmBL4Krh0Kv08cX6eR4X9S14CQ90PlCfD8fSxgZ-mDuh5FURMMyE6o-3KD8Bh_nHDZPx_Hrd07l7KXZhP-VPN28CNc-YvBbOrvmg10Tr5RQ
```

---

Save these commands for quick reference when managing your FastAPI microservices! 🚀