FROM python:3.11-slim

WORKDIR /app

# Copy shared schemas
COPY shared/ ./shared/

# Copy service files
COPY services/user_service/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY services/user_service/app/ ./app/

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]