# Debug and Test Script for Microservices
Write-Host "🔍 Debugging Microservices Setup" -ForegroundColor Cyan

# Function to test service endpoint
function Test-ServiceEndpoint {
    param(
        [string]$ServiceName,
        [string]$Url,
        [int]$ExpectedStatus = 200
    )
    
    try {
        Write-Host "Testing $ServiceName at $Url..." -ForegroundColor Yellow
        $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 10
        if ($response.StatusCode -eq $ExpectedStatus) {
            Write-Host "✅ $ServiceName is responding (Status: $($response.StatusCode))" -ForegroundColor Green
            return $true
        } else {
            Write-Host "⚠️ $ServiceName returned unexpected status: $($response.StatusCode)" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "❌ $ServiceName is not responding: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to check Docker container status
function Check-ContainerStatus {
    Write-Host "`n📦 Checking Docker Container Status..." -ForegroundColor Cyan
    docker-compose -f deployment/docker/docker-compose.yml ps
}

# Function to show service logs
function Show-ServiceLogs {
    param([string]$ServiceName)
    Write-Host "`n📋 Showing logs for $ServiceName..." -ForegroundColor Cyan
    docker-compose -f deployment/docker/docker-compose.yml logs --tail=20 $ServiceName
}

# Main debugging process
Write-Host "`n🚀 Starting service diagnostics..." -ForegroundColor Green

# Check container status
Check-ContainerStatus

Write-Host "`n🌐 Testing all service endpoints..." -ForegroundColor Cyan

# Test all services
$services = @(
    @{ Name = "User Service (Direct)"; Url = "http://localhost:8001" },
    @{ Name = "Task Service (Direct)"; Url = "http://localhost:8002" },
    @{ Name = "Notification Service (Direct)"; Url = "http://localhost:8003" },
    @{ Name = "Kong Proxy"; Url = "http://localhost:8000" },
    @{ Name = "Kong Admin"; Url = "http://localhost:8444" },
    @{ Name = "Users via Kong"; Url = "http://localhost:8000/users" },
    @{ Name = "Tasks via Kong"; Url = "http://localhost:8000/tasks" },
    @{ Name = "Notifications via Kong"; Url = "http://localhost:8000/notifications" },
    @{ Name = "pgAdmin"; Url = "http://localhost:5050" },
    @{ Name = "Kafka UI"; Url = "http://localhost:8080" },
    @{ Name = "ZooKeeper Navigator"; Url = "http://localhost:9000" },
    @{ Name = "Konga (Kong UI)"; Url = "http://localhost:1337" }
)

$workingServices = 0
$totalServices = $services.Count

foreach ($service in $services) {
    if (Test-ServiceEndpoint -ServiceName $service.Name -Url $service.Url) {
        $workingServices++
    }
    Start-Sleep -Seconds 1
}

Write-Host "`n📊 Service Status Summary:" -ForegroundColor Cyan
Write-Host "✅ Working Services: $workingServices/$totalServices" -ForegroundColor Green

if ($workingServices -lt $totalServices) {
    Write-Host "`n🔍 Troubleshooting failing services..." -ForegroundColor Yellow
    
    # Show logs for potentially failing services
    $containerNames = @("user_service", "task_service", "notification_service", "kong", "kafka", "zookeeper")
    
    foreach ($container in $containerNames) {
        Write-Host "`n--- Logs for $container ---" -ForegroundColor Magenta
        Show-ServiceLogs -ServiceName $container
    }
}

Write-Host "`n🎯 Service Access URLs:" -ForegroundColor Cyan
Write-Host "Direct Services:" -ForegroundColor Yellow
Write-Host "  • User Service:         http://localhost:8001"
Write-Host "  • Task Service:         http://localhost:8002"
Write-Host "  • Notification Service: http://localhost:8003"
Write-Host ""
Write-Host "Via Kong Gateway:" -ForegroundColor Yellow
Write-Host "  • All Services:         http://localhost:8000"
Write-Host "  • Users API:            http://localhost:8000/users"
Write-Host "  • Tasks API:            http://localhost:8000/tasks"
Write-Host "  • Notifications API:    http://localhost:8000/notifications"
Write-Host ""
Write-Host "Management UIs:" -ForegroundColor Yellow
Write-Host "  • Kong Admin:           http://localhost:8444"
Write-Host "  • Konga (Kong UI):      http://localhost:1337"
Write-Host "  • pgAdmin:              http://localhost:5050"
Write-Host "  • Kafka UI:             http://localhost:8080"
Write-Host "  • ZooKeeper Navigator:  http://localhost:9000"

Write-Host "`n💡 Quick Test Commands:" -ForegroundColor Cyan
Write-Host "# Test User Service"
Write-Host 'curl -X POST http://localhost:8000/users -H "Content-Type: application/json" -d "{\"username\":\"test\",\"email\":\"test@example.com\",\"password\":\"password\"}"'
Write-Host ""
Write-Host "# Test Task Service"  
Write-Host 'curl -X POST http://localhost:8000/tasks -H "Content-Type: application/json" -d "{\"title\":\"Test Task\",\"description\":\"Test Description\",\"user_id\":1}"'
Write-Host ""
Write-Host "# Check Notification Service"
Write-Host "curl http://localhost:8000/notifications/health"

Write-Host "`n✅ Debugging complete!" -ForegroundColor Green