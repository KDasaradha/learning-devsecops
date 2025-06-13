import os

DATABASE_URL = os.environ.get("DATABASE_URL", "postgresql://user:password@db:5432/dbname")
KAFKA_BROKER = os.environ.get("KAFKA_BROKER", "kafka:9092")