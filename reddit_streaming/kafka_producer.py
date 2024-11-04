"""Module to produce messages to a Kafka topic."""
import kafka

class KafkaProducer:
    """Class to produce messages to a Kafka topic"""

    def __init__(self, bootstrap_servers: str, topic: str):
        """Initialize the Kafka producer with the provided bootstrap servers and topic.

        Args:
            bootstrap_servers (str): The list of Kafka brokers in the format 'host:port'.
            topic (str): The name of the Kafka topic to produce messages to.
        """
        self.bootstrap_servers = bootstrap_servers
        self.topic = topic
        self.producer = kafka.KafkaProducer(bootstrap_servers=bootstrap_servers)

    def produce_message(self, message: str):
        """Produce a message to the Kafka topic.

        Args:
            message (str): The message to produce.
        """
        self.producer.send(self.topic, message.encode('utf-8'))

    def flush(self):
        """Flush any pending messages in the Kafka producer."""
        self.producer.flush()

    def close(self):
        """Close the Kafka producer."""
        self.flush()
        self.producer.close()
