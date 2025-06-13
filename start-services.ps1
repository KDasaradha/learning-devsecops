# Start All Services Script
Write-Host "🚀 Starting DevSecOps Microservices..." -ForegroundColor Cyan

Write-Host "Building and starting all services..." -ForegroundColor Yellow
docker-compose -f deployment/docker/docker-compose.yml up --build -d

Write-Host "Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "✅ Services started!" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 Available Services:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "Direct Access:" -ForegroundColor Yellow
Write-Host "  🟢 User Service:         http://localhost:8001"
Write-Host "  🟢 Task Service:         http://localhost:8002"  
Write-Host "  🟢 Notification Service: http://localhost:8003"
Write-Host ""
Write-Host "Via Kong Gateway:" -ForegroundColor Yellow
Write-Host "  🌐 Main Proxy:           http://localhost:8000"
Write-Host "  📝 Users API:            http://localhost:8000/users"
Write-Host "  📋 Tasks API:            http://localhost:8000/tasks"
Write-Host "  🔔 Notifications API:    http://localhost:8000/notifications"
Write-Host ""
Write-Host "Management Interfaces:" -ForegroundColor Yellow
Write-Host "  ⚙️  Kong Admin:           http://localhost:8444"
Write-Host "  🎛️  Konga (Kong UI):      http://localhost:1337"
Write-Host "  🐘 pgAdmin:              http://localhost:5050"
Write-Host "  📊 Kafka UI:             http://localhost:8080"
Write-Host "  🦓 ZooKeeper Navigator:  http://localhost:9000"
Write-Host ""
Write-Host "Database:" -ForegroundColor Yellow
Write-Host "  📊 PostgreSQL:           localhost:5432"
Write-Host "  📨 Kafka:                localhost:9092"
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host ""
Write-Host "💡 Quick Test:" -ForegroundColor Cyan
Write-Host "Run: .\debug-services.ps1 to check all service health"
Write-Host ""
Write-Host "📋 Credentials:" -ForegroundColor Cyan
Write-Host "  • pgAdmin:    admin@example.com / admin"
Write-Host "  • PostgreSQL: user / password"