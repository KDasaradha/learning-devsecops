from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .db import SessionLocal
from .models import User
from .kafka_producer import kafka_producer
from shared.common_schemas import UserCreate, UserRead
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/")
def root():
    return {"service": "user-service", "status": "running", "version": "1.0.0"}

@router.get("/health")
def health():
    return {"status": "healthy", "service": "user-service"}

@router.post("/users/", response_model=UserRead)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    db_user = User(username=user.username, email=user.email, password=user.password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    # Publish user created event to Kafka
    try:
        event_data = {
            "id": db_user.id,
            "username": db_user.username,
            "email": db_user.email,
            "event_type": "user.created"
        }
        kafka_producer.produce_event("user.created", event_data)
        logger.info(f"Published user.created event for user {db_user.id}")
    except Exception as e:
        logger.error(f"Failed to publish user.created event: {e}")
    
    return db_user

@router.get("/users/", response_model=list[UserRead])
def list_users(db: Session = Depends(get_db)):
    return db.query(User).all()

@router.get("/users/{user_id}", response_model=UserRead)
def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user