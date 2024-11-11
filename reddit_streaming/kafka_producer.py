"""Module to produce messages to a Kafka topic."""
import logging

from confluent_kafka import Producer

logger = logging.getLogger(__name__)


def delivery_report(err: Exception, msg):
    """ Called once for each message produced to indicate delivery result.
        Triggered by poll() or flush(). """
    if err is not None:
        logger.error('Message delivery failed: {}'.format(err))
    else:
        logger.debug('Message delivered to {} [{}]'.format(msg.topic(), msg.partition()))

class KafkaMessageProducer:
    """Class to produce messages to a Kafka topic"""

    def __init__(self, bootstrap_servers: str, topic: str):
        """Initialize the Kafka producer with the provided bootstrap servers and topic.

        Args:
            bootstrap_servers (str): The list of Kafka brokers in the format 'host:port'.
            topic (str): The name of the Kafka topic to produce messages to.
        """
        config = {
            "bootstrap.servers": bootstrap_servers,
            # "security.protocol": "SSL",
        }

        self.bootstrap_servers = bootstrap_servers
        self.topic = topic
        self.producer = Producer(config)

    def produce_message(self, message: str):
        """Produce a message to the Kafka topic.

        Args:
            message (str): The message to produce.
        """
        self.producer.produce(self.topic, message.encode('utf-8'), callback=delivery_report)
        logger.debug(f"Produced message to topic {self.topic}: {message}")

    def flush(self):
        """Flush any pending messages in the Kafka producer."""
        self.producer.flush()

    def close(self):
        """Close the Kafka producer."""
        self.producer.poll(10000)
        self.flush()
        logger.info("Closed Kafka producer")

class MockProducer:
    """Mock class to simulate a Kafka producer for testing purposes."""

    def __init__(self, bootstrap_servers: str, topic: str):
        """Initialize the mock producer."""
        pass

    def produce_message(self, message: str) -> None:
        """Simulate producing a message.

        Args:
            message (str): The message to produce.
        """
        logger.debug(f"[MOCK PRODUCER] Producing message: {message}")

    def flush(self) -> None:
        """Simulate flushing the producer."""
        logger.debug("[MOCK PRODUCER] Flushing producer")

    def close(self) -> None:
        """Simulate closing the producer."""
        logger.debug("[MOCK PRODUCER] Closing producer")
