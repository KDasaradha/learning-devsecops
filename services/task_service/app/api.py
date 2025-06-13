from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .db import SessionLocal
from .models import Task
from .kafka_producer import kafka_producer
from shared.common_schemas import TaskCreate, TaskRead
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
    return {"service": "task-service", "status": "running", "version": "1.0.0"}

@router.get("/health")
def health():
    return {"status": "healthy", "service": "task-service"}

@router.post("/tasks/", response_model=TaskRead)
def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    db_task = Task(title=task.title, description=task.description, user_id=task.user_id)
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    
    # Publish task created event to Kafka
    try:
        event_data = {
            "id": db_task.id,
            "title": db_task.title,
            "description": db_task.description,
            "user_id": db_task.user_id,
            "event_type": "task.created"
        }
        kafka_producer.produce_event("task.created", event_data)
        logger.info(f"Published task.created event for task {db_task.id}")
    except Exception as e:
        logger.error(f"Failed to publish task.created event: {e}")
    
    return db_task

@router.get("/tasks/", response_model=list[TaskRead])
def list_tasks(db: Session = Depends(get_db)):
    return db.query(Task).all()

@router.get("/tasks/user/{user_id}", response_model=list[TaskRead])
def get_tasks_by_user(user_id: int, db: Session = Depends(get_db)):
    return db.query(Task).filter(Task.user_id == user_id).all()