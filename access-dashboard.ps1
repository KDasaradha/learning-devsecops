#!/usr/bin/env pwsh
# Kubernetes Dashboard Access Helper Script

Write-Host '🖥️ Kubernetes Dashboard Access Helper' -ForegroundColor Green

# Check if kubectl is available
if (!(Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host '❌ kubectl not found. Please install kubectl.' -ForegroundColor Red
    exit 1
}

# Check if dashboard is installed
Write-Host '📋 Checking if dashboard is installed...' -ForegroundColor Yellow
$dashboardExists = kubectl get namespace kubernetes-dashboard 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host '❌ Kubernetes Dashboard is not installed. Run ./deploy-k8s.ps1 first.' -ForegroundColor Red
    exit 1
}

Write-Host '✅ Dashboard is installed' -ForegroundColor Green

# Generate new token
Write-Host "`n🔑 Generating access token..." -ForegroundColor Yellow
$token = kubectl -n kubernetes-dashboard create token admin-user
if ($LASTEXITCODE -ne 0) {
    Write-Host '❌ Failed to generate token. Make sure admin-user exists.' -ForegroundColor Red
    exit 1
}

Write-Host '✅ Token generated successfully' -ForegroundColor Green

# Display instructions
Write-Host "`n📋 Dashboard Access Instructions:" -ForegroundColor Cyan
Write-Host "`n1. 🚀 Start kubectl proxy (in a separate terminal):" -ForegroundColor Yellow
Write-Host "   kubectl proxy" -ForegroundColor White

Write-Host "`n2. 🌐 Open your browser and navigate to:" -ForegroundColor Yellow
Write-Host "   http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/" -ForegroundColor Blue

Write-Host "`n3. 🔐 Use this token to login:" -ForegroundColor Yellow
Write-Host "   $token" -ForegroundColor Green

Write-Host "`n📋 Token saved to clipboard (if available)" -ForegroundColor Cyan
try {
    $token | Set-Clipboard
    Write-Host '✅ Token copied to clipboard!' -ForegroundColor Green
} catch {
    Write-Host '⚠️ Could not copy to clipboard (clipboard not available)' -ForegroundColor Yellow
}

Write-Host "`n🎯 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Run 'kubectl proxy' in a new terminal" -ForegroundColor White
Write-Host "   2. Open the URL above in your browser" -ForegroundColor White
Write-Host "   3. Select 'Token' authentication method" -ForegroundColor White
Write-Host "   4. Paste the token and click 'Sign In'" -ForegroundColor White

Write-Host "`n🔄 To get a new token later, run this script again!" -ForegroundColor Magenta