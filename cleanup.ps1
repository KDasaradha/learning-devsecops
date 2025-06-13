# Comprehensive Cleanup script for Docker containers and volumes
Write-Host "🧹 Starting comprehensive cleanup..." -ForegroundColor Cyan

Write-Host "Stopping all containers..." -ForegroundColor Yellow
docker-compose -f deployment/docker/docker-compose.yml down -v --remove-orphans

Write-Host "Removing all project volumes..." -ForegroundColor Yellow
$volumes = @(
    "learning-devsecops_pgdata",
    "learning-devsecops_pgadmin_data", 
    "learning-devsecops_kafka_data",
    "learning-devsecops_zookeeper_data"
)

foreach ($volume in $volumes) {
    Write-Host "Removing volume: $volume"
    docker volume rm $volume 2>$null
}

Write-Host "Removing dangling volumes..." -ForegroundColor Yellow
$danglingVolumes = docker volume ls -q --filter dangling=true
if ($danglingVolumes) {
    docker volume rm $danglingVolumes 2>$null
}

Write-Host "Removing unused networks..." -ForegroundColor Yellow
docker network prune -f

Write-Host "Removing unused images..." -ForegroundColor Yellow
docker image prune -f

Write-Host "Cleaning up build cache..." -ForegroundColor Yellow
docker builder prune -f

Write-Host "✅ Cleanup completed!" -ForegroundColor Green
Write-Host "You can now run: docker-compose -f deployment/docker/docker-compose.yml up --build" -ForegroundColor Cyan