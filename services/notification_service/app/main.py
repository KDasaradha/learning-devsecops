import asyncio
import json
import logging
from fastapi import FastAPI
from confluent_kafka import Consumer, KafkaError
from .config import KAFKA_BROKER
import uvicorn
from threading import Thread

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# FastAPI app for health checks and status
app = FastAPI(title="Notification Service")

class NotificationService:
    def __init__(self):
        self.consumer = Consumer({
            'bootstrap.servers': KAFKA_BROKER,
            'group.id': 'notification-service',
            'auto.offset.reset': 'earliest'
        })
        self.consumer.subscribe(['user.created', 'task.created'])
    
    def process_user_created(self, event_data):
        """Process user created event."""
        global service_status
        logger.info(f"🎉 New user registered: {event_data.get('username')} ({event_data.get('email')})")
        service_status["processed_events"] += 1
        # Here you could send welcome email, push notification, etc.
        # For now, we'll just log the event
    
    def process_task_created(self, event_data):
        """Process task created event."""
        global service_status
        logger.info(f"📝 New task created: '{event_data.get('title')}' by user {event_data.get('user_id')}")
        service_status["processed_events"] += 1
        # Here you could send task notification, update dashboards, etc.
        # For now, we'll just log the event
    
    async def consume_events(self):
        """Consume events from Kafka topics."""
        logger.info("Starting notification service consumer...")
        
        try:
            while True:
                msg = self.consumer.poll(timeout=1.0)
                
                if msg is None:
                    continue
                
                if msg.error():
                    if msg.error().code() == KafkaError._PARTITION_EOF:
                        logger.info(f"End of partition reached {msg.topic()} [{msg.partition()}] at offset {msg.offset()}")
                    else:
                        logger.error(f"Consumer error: {msg.error()}")
                    continue
                
                try:
                    event_data = json.loads(msg.value().decode('utf-8'))
                    topic = msg.topic()
                    
                    logger.info(f"Received event from {topic}: {event_data}")
                    
                    if topic == 'user.created':
                        self.process_user_created(event_data)
                    elif topic == 'task.created':
                        self.process_task_created(event_data)
                    
                except json.JSONDecodeError as e:
                    logger.error(f"Failed to decode message: {e}")
                except Exception as e:
                    logger.error(f"Error processing message: {e}")
                
                await asyncio.sleep(0.1)  # Small delay to prevent tight loop
                
        except KeyboardInterrupt:
            logger.info("Shutting down notification service...")
        finally:
            self.consumer.close()

# Global variable to track service status
service_status = {"status": "starting", "processed_events": 0}

@app.get("/")
async def root():
    return {"service": "notification-service", "status": "running"}

@app.get("/health")
async def health():
    return service_status

@app.get("/stats")
async def stats():
    return {
        "service": "notification-service",
        "status": service_status["status"],
        "processed_events": service_status["processed_events"]
    }

async def run_consumer():
    """Run the Kafka consumer in the background."""
    global service_status
    service_status["status"] = "running"
    
    service = NotificationService()
    await service.consume_events()

def start_consumer():
    """Start the consumer in a separate thread."""
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    loop.run_until_complete(run_consumer())

if __name__ == "__main__":
    # Start consumer in background thread
    consumer_thread = Thread(target=start_consumer, daemon=True)
    consumer_thread.start()
    
    # Start FastAPI server
    uvicorn.run(app, host="0.0.0.0", port=8000)