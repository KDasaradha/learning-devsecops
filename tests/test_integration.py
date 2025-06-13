import pytest
import requests
import time
import os

# These tests will run against the actual running services
# They require the full stack to be running

BASE_URL = "http://localhost:8000"  # Kong Gateway URL
USER_SERVICE_URL = "http://localhost:8001"
TASK_SERVICE_URL = "http://localhost:8002"
NOTIFICATION_SERVICE_URL = "http://localhost:8003"

@pytest.mark.integration
def test_services_health():
    """Test that all services are healthy."""
    # Skip if not in integration test mode
    if not os.getenv("INTEGRATION_TEST"):
        pytest.skip("Skipping integration test")
    
    # Test direct service health
    response = requests.get(f"{USER_SERVICE_URL}/health", timeout=5)
    assert response.status_code == 200
    
    response = requests.get(f"{TASK_SERVICE_URL}/health", timeout=5)
    assert response.status_code == 200
    
    response = requests.get(f"{NOTIFICATION_SERVICE_URL}/health", timeout=5)
    assert response.status_code == 200

@pytest.mark.integration
def test_user_workflow_via_kong():
    """Test complete user workflow through Kong gateway."""
    if not os.getenv("INTEGRATION_TEST"):
        pytest.skip("Skipping integration test")
    
    # Create a user
    user_data = {
        "username": f"testuser_{int(time.time())}",
        "email": f"test_{int(time.time())}@example.com",
        "password": "testpassword123"
    }
    
    response = requests.post(
        f"{BASE_URL}/users",
        json=user_data,
        timeout=10
    )
    assert response.status_code == 200
    user = response.json()
    assert "id" in user
    user_id = user["id"]
    
    # List users
    response = requests.get(f"{BASE_URL}/users", timeout=10)
    assert response.status_code == 200
    users = response.json()
    assert len(users) > 0
    
    # Create a task for the user
    task_data = {
        "title": "Integration Test Task",
        "description": "This task was created during integration testing",
        "user_id": user_id
    }
    
    response = requests.post(
        f"{BASE_URL}/tasks",
        json=task_data,
        timeout=10
    )
    assert response.status_code == 200
    task = response.json()
    assert task["title"] == task_data["title"]
    assert task["user_id"] == user_id
    
    # List tasks
    response = requests.get(f"{BASE_URL}/tasks", timeout=10)
    assert response.status_code == 200
    tasks = response.json()
    assert len(tasks) > 0

@pytest.mark.integration
def test_kong_admin_api():
    """Test Kong admin API is accessible."""
    if not os.getenv("INTEGRATION_TEST"):
        pytest.skip("Skipping integration test")
    
    response = requests.get("http://localhost:8444/services", timeout=10)
    assert response.status_code == 200
    services = response.json()
    assert "data" in services
    
    # Check that our services are registered
    service_names = [service["name"] for service in services["data"]]
    assert "user-service" in service_names
    assert "task-service" in service_names
    assert "notification-service" in service_names