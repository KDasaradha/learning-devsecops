# DevSecOps Pipeline Status Dashboard
Write-Host "🔄 DevSecOps Pipeline Status Dashboard" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Function to check if a command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Function to run tests locally
function Run-LocalTests {
    Write-Host "`n🧪 Running Local Tests..." -ForegroundColor Yellow
    
    if (Test-Command pytest) {
        Write-Host "Running unit tests..." -ForegroundColor White
        pytest tests/ -v --tb=short
    } else {
        Write-Host "❌ pytest not found. Install with: pip install pytest" -ForegroundColor Red
    }
}

# Function to run security scans
function Run-SecurityScans {
    Write-Host "`n🛡️ Running Security Scans..." -ForegroundColor Yellow
    
    # Check if security tools are available
    $tools = @("bandit", "safety", "ruff")
    $missingTools = @()
    
    foreach ($tool in $tools) {
        if (!(Test-Command $tool)) {
            $missingTools += $tool
        }
    }
    
    if ($missingTools.Count -gt 0) {
        Write-Host "❌ Missing security tools: $($missingTools -join ', ')" -ForegroundColor Red
        Write-Host "Install with: pip install bandit safety ruff" -ForegroundColor Yellow
        return
    }
    
    # Run Bandit (security scanner)
    Write-Host "Running Bandit security scan..." -ForegroundColor White
    bandit -r services/ -ll
    
    # Run Safety (dependency vulnerability scanner)
    Write-Host "`nRunning Safety dependency check..." -ForegroundColor White
    safety check
    
    # Run Ruff (linter)
    Write-Host "`nRunning Ruff linter..." -ForegroundColor White
    ruff check .
}

# Function to check Docker setup
function Test-DockerSetup {
    Write-Host "`n🐳 Checking Docker Setup..." -ForegroundColor Yellow
    
    if (!(Test-Command docker)) {
        Write-Host "❌ Docker not found!" -ForegroundColor Red
        return $false
    }
    
    if (!(Test-Command docker-compose)) {
        Write-Host "❌ Docker Compose not found!" -ForegroundColor Red
        return $false
    }
    
    # Check if Docker is running
    try {
        docker ps | Out-Null
        Write-Host "✅ Docker is running" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Docker daemon is not running" -ForegroundColor Red
        return $false
    }
    
    # Check if services are running
    $runningContainers = docker ps --format "table {{.Names}}" | Select-String -Pattern "(user_service|task_service|notification_service|kong|postgres|kafka)"
    
    if ($runningContainers) {
        Write-Host "✅ Some services are running:" -ForegroundColor Green
        $runningContainers | ForEach-Object { Write-Host "  • $_" -ForegroundColor White }
    } else {
        Write-Host "⚠️ No services are currently running" -ForegroundColor Yellow
        Write-Host "Run: .\start-services.ps1 to start all services" -ForegroundColor Cyan
    }
    
    return $true
}

# Function to simulate CI/CD pipeline locally
function Run-LocalPipeline {
    Write-Host "`n🚀 Running Local CI/CD Pipeline Simulation..." -ForegroundColor Yellow
    
    # Step 1: Security Scan
    Write-Host "`n📋 Step 1: Security & Code Quality" -ForegroundColor Cyan
    Run-SecurityScans
    
    # Step 2: Unit Tests
    Write-Host "`n📋 Step 2: Unit Tests" -ForegroundColor Cyan
    Run-LocalTests
    
    # Step 3: Integration Tests (if services are running)
    Write-Host "`n📋 Step 3: Integration Tests" -ForegroundColor Cyan
    $dockerRunning = Test-DockerSetup
    
    if ($dockerRunning) {
        Write-Host "Running integration tests..." -ForegroundColor White
        $env:INTEGRATION_TEST = "1"
        if (Test-Command pytest) {
            pytest tests/test_integration.py -v -m integration
        }
        Remove-Item Env:\INTEGRATION_TEST -ErrorAction SilentlyContinue
    } else {
        Write-Host "⚠️ Docker not running, skipping integration tests" -ForegroundColor Yellow
    }
    
    # Step 4: Build (Docker images)
    Write-Host "`n📋 Step 4: Build Docker Images" -ForegroundColor Cyan
    if ($dockerRunning) {
        Write-Host "Building Docker images..." -ForegroundColor White
        docker-compose -f deployment/docker/docker-compose.yml build
    }
    
    Write-Host "`n✅ Local pipeline simulation completed!" -ForegroundColor Green
}

# Main menu
Write-Host "`n🎯 Available Actions:" -ForegroundColor White
Write-Host "1. Run Local Pipeline Simulation"
Write-Host "2. Run Security Scans Only"
Write-Host "3. Run Unit Tests Only"
Write-Host "4. Check Docker Setup"
Write-Host "5. Check Service Health"
Write-Host "6. View Pipeline Components"
Write-Host ""

$choice = Read-Host "Select an option (1-6) or press Enter to run full pipeline"

switch ($choice) {
    "1" { Run-LocalPipeline }
    "2" { Run-SecurityScans }
    "3" { Run-LocalTests }
    "4" { Test-DockerSetup }
    "5" { & ".\debug-services.ps1" }
    "6" { 
        Write-Host "`n📊 CI/CD Pipeline Components:" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        Write-Host "🛡️ Security Scanning:"
        Write-Host "  • Bandit - Python security linter"
        Write-Host "  • Safety - Dependency vulnerability scanner"
        Write-Host "  • Semgrep - Static analysis security tool"
        Write-Host "  • Trivy - Container vulnerability scanner"
        Write-Host ""
        Write-Host "🧪 Testing:"
        Write-Host "  • Unit tests with pytest"
        Write-Host "  • Integration tests with real services"
        Write-Host "  • API endpoint testing"
        Write-Host "  • Code coverage reporting"
        Write-Host ""
        Write-Host "🔍 Code Quality:"
        Write-Host "  • Ruff - Fast Python linter"
        Write-Host "  • Black - Code formatter"
        Write-Host "  • isort - Import sorter"
        Write-Host "  • MyPy - Type checking"
        Write-Host ""
        Write-Host "🚀 Deployment:"
        Write-Host "  • Docker image building"
        Write-Host "  • Container security scanning"
        Write-Host "  • Staging deployment"
        Write-Host "  • Smoke testing"
        Write-Host ""
        Write-Host "📊 Reporting:"
        Write-Host "  • Security summary reports"
        Write-Host "  • Test coverage reports"
        Write-Host "  • Container scan results"
    }
    default { Run-LocalPipeline }
}

Write-Host "`n✨ DevSecOps Pipeline Status Complete!" -ForegroundColor Green