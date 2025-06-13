from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .db import SessionLocal
from .models import Task
from shared.common_schemas import TaskCreate, TaskRead

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/tasks/", response_model=TaskRead)
def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    db_task = Task(title=task.title, description=task.description, user_id=task.user_id)
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    # Publish to Kafka here (stub)
    return db_task

@router.get("/tasks/", response_model=list[TaskRead])
def list_tasks(db: Session = Depends(get_db)):
    return db.query(Task).all()

@router.get("/tasks/user/{user_id}", response_model=list[TaskRead])
def get_tasks_by_user(user_id: int, db: Session = Depends(get_db)):
    return db.query(Task).filter(Task.user_id == user_id).all()