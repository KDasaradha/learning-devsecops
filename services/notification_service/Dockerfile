FROM python:3.11-slim

WORKDIR /app

# Copy shared schemas
COPY shared/ ./shared/

# Copy service files
COPY services/notification_service/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY services/notification_service/app/ ./app/

CMD ["python", "-m", "app.main"]