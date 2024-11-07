"""Main module of the program."""
import argparse
import json
import logging
from threading import Thread
import time
from typing import Union

from reddit_streaming.api_credentials_manager import APICredentialsManager
from reddit_streaming.reddit_client import RedditClient
from reddit_streaming.kafka_producer import KafkaMessageProducer, MockProducer


def configure_logging(dry_run: bool = False):
    """Set up logging configuration.

    Args:
        dry_run (bool): Whether to run the program in dry-run
    """
    level = logging.DEBUG if dry_run else logging.INFO
    logging.basicConfig(
        level=level,  # Change this to logging.DEBUG for more verbose logs
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(),  # Send logs to stdout
        ]
    )
    logging.info("Logging configured successfully")


def produce_messages(
        subreddit: str,
        limit: int,
        interval: int,
        reddit_client: RedditClient,
        producer: Union[KafkaMessageProducer, MockProducer]
):
    """Producer function to fetch posts from a subreddit and produce them to a Kafka topic.

    Args:
        subreddit (str): The subreddit to fetch posts from.
        limit (int): The number of posts to fetch.
        interval (int): The interval in seconds to wait between producing messages.
        reddit_client (RedditClient): The Reddit client instance.
        producer (KafkaMessageProducer): The Kafka producer instance.
    """

    while True:
        posts = reddit_client.fetch_posts(subreddit_name=subreddit, limit=limit)

        for post in posts:
            json_post = json.dumps(post.to_dict())
            producer.produce_message(json_post)

        # Flush and close the Kafka producer
        producer.close()

        time.sleep(interval)

def main(
        subreddit: str,
        limit: int,
        bootstrap_servers: str,
        topic: str,
        client_id: str,
        client_secret: str,
        user_agent: str,
        dry_run: bool = False,
        num_producers: int = 1,
        interval: int = 60
):
    """Main entry point of the program.

    Args:
        subreddit (str): The subreddit to fetch posts from.
        limit (int): The number of posts to fetch.
        bootstrap_servers (str): The Kafka bootstrap servers.
        topic (str): The Kafka topic to produce messages to.
        client_id (str): The client ID for the Reddit API.
        client_secret (str): The client secret for the Reddit API.
        user_agent (str): The user agent for the Reddit API.
        dry_run (bool): Whether to run the program in dry-run mode.
        num_producers (int): The number of producers to simulate.
        interval (int): The interval in seconds to wait between producing messages.
    """
    configure_logging(dry_run)
    logger = logging.getLogger(__name__)
    logger.info("Starting Reddit Streaming Application")

    # Read API credentials from a JSON file
    credentials_manager = APICredentialsManager(client_id=client_id, client_secret=client_secret, user_agent=user_agent)
    credentials_manager.read_from_env()

    # Initialize the Reddit client
    reddit_client = RedditClient(credentials_manager)
    reddit_client.authenticate()

    # Choose the appropriate producer
    producer_class = MockProducer if dry_run else KafkaMessageProducer
    producer = producer_class(bootstrap_servers=bootstrap_servers, topic=topic)

    # Create and start producer threads
    producer_threads = []
    for _ in range(num_producers):
        producer_thread = Thread(
            target=produce_messages,
            args=(subreddit, limit, interval, reddit_client, producer)
        )
        producer_thread.start()
        producer_threads.append(producer_thread)

    # Wait for all threads to complete
    for producer_thread in producer_threads:
        producer_thread.join()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Reddit Streaming Application')
    parser.add_argument('--subreddit', type=str, default='python', help='The subreddit to fetch posts from')
    parser.add_argument('--limit', type=int, default=10, help='The number of posts to fetch')
    parser.add_argument('--bootstrap-servers', type=str, default='localhost:9092', help='The Kafka bootstrap servers')
    parser.add_argument('--topic', type=str, default='reddit_posts', help='The Kafka topic to produce messages to')
    parser.add_argument('--client-id', type=str, help='The client ID for the Reddit API')
    parser.add_argument('--client-secret', type=str, help='The client secret for the Reddit API')
    parser.add_argument('--user-agent', type=str, help='The user agent for the Reddit API')
    parser.add_argument('--dry-run', action='store_true', help='Run the program in dry-run mode')
    parser.add_argument('--num-producers', type=int, default=1, help='The number of producers to simulate')
    parser.add_argument('--interval', type=int, default=60, help='The interval in seconds to wait between producing messages')

    args = parser.parse_args()

    main(
        subreddit=args.subreddit,
        limit=args.limit,
        bootstrap_servers=args.bootstrap_servers,
        topic=args.topic,
        client_id=args.client_id,
        client_secret=args.client_secret,
        user_agent=args.user_agent,
        dry_run=args.dry_run,
        num_producers=args.num_producers,
        interval=args.interval
    )
