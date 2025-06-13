from fastapi.testclient import TestClient
from services.notification_service.app.main import app

client = TestClient(app)

def test_notification_service_root():
    """Test notification service root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "notification-service"
    assert data["status"] == "running"

def test_notification_service_health():
    """Test notification service health endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert "status" in data
    assert "processed_events" in data

def test_notification_service_stats():
    """Test notification service stats endpoint."""
    response = client.get("/stats")
    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "notification-service"
    assert "status" in data
    assert "processed_events" in data