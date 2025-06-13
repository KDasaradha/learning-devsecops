# Troubleshooting Guide

## Issues Fixed

### 1. Kong Route Error
**Issue**: "no Route matched with those values" when accessing Kong on port 8444:8001

**Solution**: 
- Kong routes are configured properly in `api_gateway/kong/kong.yml`
- Access services through Kong proxy on port 8000:
  - Users API: `http://localhost:8000/users`
  - Tasks API: `http://localhost:8000/tasks`
- Kong Admin API is available on: `http://localhost:8444`

### 2. SQLAlchemy Foreign Key Error
**Issue**: Task service couldn't find 'users' table for foreign key constraint

**Solution**: 
- Removed foreign key constraint from Task model
- Services now create their own tables independently
- User ID is stored as a regular integer field
- Application-level validation should be implemented for user existence

### 3. Kafka ZooKeeper Error
**Issue**: "NodeExists" error when Kafka tries to register with ZooKeeper

**Solutions Applied**:
- Added persistent volumes for Kafka and ZooKeeper data
- Added health checks for better service startup coordination
- Added service dependencies with health conditions

### 4. pgAdmin Added
**New Feature**: pgAdmin is now available for database management
- URL: `http://localhost:5050`
- Username: `admin@example.com`
- Password: `admin`

## Quick Start

### 1. Clean Previous Installation
```powershell
# Run the cleanup script
.\cleanup.ps1
```

### 2. Start Services
```powershell
cd deployment/docker
docker-compose up --build
```

### 3. Verify Services

#### Direct Service Access:
- **Users Service**: http://localhost:8001
- **Tasks Service**: http://localhost:8002  
- **Notification Service**: http://localhost:8003

#### Via Kong Gateway:
- **Kong Proxy**: http://localhost:8000
- **Users API**: http://localhost:8000/users
- **Tasks API**: http://localhost:8000/tasks
- **Notifications API**: http://localhost:8000/notifications
- **Kong Admin**: http://localhost:8444

#### Management UIs:
- **pgAdmin**: http://localhost:5050
- **Kafka UI**: http://localhost:8080 (NEW!)
- **ZooKeeper Navigator**: http://localhost:9000 (NEW!)
- **Konga (Kong UI)**: http://localhost:1337 (NEW!)

#### Backend Services:
- **PostgreSQL**: localhost:5432
- **Kafka**: localhost:9092

### 4. Connect to Database via pgAdmin
1. Open http://localhost:5050
2. Login with admin@example.com / admin
3. Add new server connection:
   - Host: `db` (or `host.docker.internal` if connecting from host)
   - Port: `5432`
   - Database: `dbname`
   - Username: `user`
   - Password: `password`

## Testing API Endpoints

### Users API (via Kong)
```bash
# Create user
curl -X POST http://localhost:8000/users \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "email": "test@example.com", "password": "password123"}'

# Get users
curl http://localhost:8000/users
```

### Tasks API (via Kong)
```bash
# Create task
curl -X POST http://localhost:8000/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Task", "description": "Test Description", "user_id": 1}'

# Get tasks
curl http://localhost:8000/tasks
```

## Troubleshooting Common Issues

### Service Won't Start
- Check if all required services are healthy: `docker-compose ps`
- Check service logs: `docker-compose logs <service_name>`
- Ensure ports are not already in use

### Database Connection Issues
- Verify PostgreSQL is running and healthy
- Check database connection string in .env file
- Ensure services wait for database to be ready

### Kafka Issues
- Clean up Kafka/ZooKeeper volumes if needed
- Check ZooKeeper is running before Kafka starts
- Verify Kafka broker is accessible on localhost:9092

## Architecture Notes

The microservices architecture includes:
- **User Service**: Manages user data and authentication
- **Task Service**: Manages tasks (references users by ID)
- **Notification Service**: Handles async notifications via Kafka
- **Kong Gateway**: API Gateway for routing and rate limiting
- **PostgreSQL**: Shared database for all services
- **Kafka**: Message broker for async communication
- **pgAdmin**: Database administration tool

Each service maintains its own data model and communicates via HTTP APIs or Kafka messages.