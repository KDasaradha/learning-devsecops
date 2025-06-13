import pytest
from fastapi.testclient import TestClient
from services.user_service.app.main import app

client = TestClient(app)

def test_create_user():
    """Test user creation."""
    response = client.post(
        "/users/",
        json={
            "username": "testuser",
            "email": "test@example.com",
            "password": "testpass123"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["username"] == "testuser"
    assert data["email"] == "test@example.com"
    assert "id" in data

def test_list_users():
    """Test listing users."""
    response = client.get("/users/")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_get_user():
    """Test getting a specific user."""
    # First create a user
    create_response = client.post(
        "/users/",
        json={
            "username": "getuser",
            "email": "getuser@example.com",
            "password": "testpass123"
        }
    )
    user_id = create_response.json()["id"]
    
    # Then get the user
    response = client.get(f"/users/{user_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["username"] == "getuser"
    assert data["email"] == "getuser@example.com"

def test_get_nonexistent_user():
    """Test getting a non-existent user."""
    response = client.get("/users/99999")
    assert response.status_code == 404