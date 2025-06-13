import pytest
from fastapi.testclient import TestClient
from services.task_service.app.main import app

client = TestClient(app)

def test_create_task():
    """Test task creation."""
    response = client.post(
        "/tasks/",
        json={
            "title": "Test Task",
            "description": "This is a test task",
            "user_id": 1
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Test Task"
    assert data["description"] == "This is a test task"
    assert data["user_id"] == 1
    assert "id" in data

def test_list_tasks():
    """Test listing tasks."""
    response = client.get("/tasks/")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_get_tasks_by_user():
    """Test getting tasks by user."""
    # First create a task
    client.post(
        "/tasks/",
        json={
            "title": "User Task",
            "description": "Task for specific user",
            "user_id": 123
        }
    )
    
    # Then get tasks for that user
    response = client.get("/tasks/user/123")
    assert response.status_code == 200
    tasks = response.json()
    assert isinstance(tasks, list)
    # Check if any task belongs to user 123
    user_tasks = [task for task in tasks if task["user_id"] == 123]
    assert len(user_tasks) > 0