#!/usr/bin/env pwsh
# Kubernetes Cleanup Script

Write-Host "🧹 Cleaning up Kubernetes resources..." -ForegroundColor Yellow

# Delete all resources in the namespace
kubectl delete namespace fastapi-app --ignore-not-found=true

# Wait for namespace deletion
Write-Host "⏳ Waiting for namespace deletion..." -ForegroundColor Yellow
kubectl wait --for=delete namespace/fastapi-app --timeout=60s 2>$null

# Stop any running port-forward jobs
$jobs = Get-Job | Where-Object { $_.Name -like "pf-*" }
if ($jobs) {
    Write-Host "🛑 Stopping port-forward jobs..." -ForegroundColor Yellow
    $jobs | Stop-Job
    $jobs | Remove-Job
}

Write-Host "✅ Cleanup completed!" -ForegroundColor Green