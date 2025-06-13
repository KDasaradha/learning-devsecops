"""
Shared database initialization for all microservices
"""
import logging
from sqlalchemy import create_engine, MetaData
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:password@db:5432/dbname")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_all_tables():
    """Initialize all tables from all services"""
    try:
        # Import all models to register them with Base
        from services.user_service.app.models import User
        from services.task_service.app.models import Task
        
        logger.info("Creating all database tables...")
        Base.metadata.create_all(bind=engine)
        logger.info("All database tables created successfully")
        
    except Exception as e:
        logger.error(f"Error creating database tables: {e}")
        raise