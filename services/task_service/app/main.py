from fastapi import FastAPI
from .db import Base, engine
from .api import router

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Task Service")
app.include_router(router)