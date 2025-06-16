#!/usr/bin/env pwsh
# Port Forward Script for Kubernetes Services

Write-Host "🔗 Setting up port forwarding for Kubernetes services..." -ForegroundColor Green

# Function to start port forwarding in background
function Start-PortForward {
    param($service, $localPort, $servicePort, $namespace)
    
    Write-Host "🔌 Port forwarding $service -> localhost:$localPort" -ForegroundColor Yellow
    Start-Job -ScriptBlock {
        param($svc, $lp, $sp, $ns)
        kubectl port-forward service/$svc $lp`:$sp -n $ns
    } -ArgumentList $service, $localPort, $servicePort, $namespace -Name "pf-$service"
}

# Check if services are running
Write-Host "📋 Checking services..." -ForegroundColor Yellow
$services = kubectl get services -n fastapi-app --no-headers 2>$null

if (!$services) {
    Write-Host "❌ No services found. Please run deploy-k8s.ps1 first." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Services found!" -ForegroundColor Green

# Start port forwarding for each service
Start-PortForward "user-service" "8001" "8000" "fastapi-app"
Start-PortForward "task-service" "8002" "8000" "fastapi-app"
Start-PortForward "notification-service" "8003" "80" "fastapi-app"
Start-PortForward "postgresql" "5432" "5432" "fastapi-app"

Write-Host "`n🌐 Services available at:" -ForegroundColor Green
Write-Host "  • User Service: http://localhost:8001/docs" -ForegroundColor White
Write-Host "  • Task Service: http://localhost:8002/docs" -ForegroundColor White  
Write-Host "  • Notification Service: http://localhost:8003/docs" -ForegroundColor White
Write-Host "  • PostgreSQL: localhost:5432" -ForegroundColor White

Write-Host "`n📝 Port forwarding jobs started. To stop:" -ForegroundColor Cyan
Write-Host "  Get-Job | Stop-Job; Get-Job | Remove-Job" -ForegroundColor White

Write-Host "`nPress Ctrl+C to stop all port forwarding..." -ForegroundColor Yellow

# Keep script running
try {
    while ($true) {
        Start-Sleep 1
    }
} finally {
    # Cleanup jobs on exit
    Get-Job | Stop-Job
    Get-Job | Remove-Job
    Write-Host "`n🛑 Port forwarding stopped." -ForegroundColor Red
}