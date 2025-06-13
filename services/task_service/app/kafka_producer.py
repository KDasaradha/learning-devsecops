import json
import logging
from confluent_kafka import Producer
from .config import KAFKA_BROKER

logger = logging.getLogger(__name__)

class KafkaProducer:
    def __init__(self):
        self.producer = Producer({
            'bootstrap.servers': KAFKA_BROKER,
            'client.id': 'task-service'
        })
    
    def delivery_report(self, err, msg):
        """Called once for each message produced to indicate delivery result."""
        if err is not None:
            logger.error(f'Message delivery failed: {err}')
        else:
            logger.info(f'Message delivered to {msg.topic()} [{msg.partition()}]')
    
    def produce_event(self, topic: str, event_data: dict):
        """Produce an event to Kafka topic."""
        try:
            self.producer.produce(
                topic,
                key=str(event_data.get('id', '')),
                value=json.dumps(event_data),
                callback=self.delivery_report
            )
            self.producer.poll(0)
        except Exception as e:
            logger.error(f"Error producing message to {topic}: {e}")

# Global producer instance
kafka_producer = KafkaProducer()