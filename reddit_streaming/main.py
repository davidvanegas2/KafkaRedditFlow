"""Main module of the program."""
import argparse
import json
from dataclasses import asdict

from reddit_streaming.api_credentials_manager import APICredentialsManager
from reddit_streaming.reddit_client import RedditClient
from reddit_streaming.kafka_producer import KafkaMessageProducer

def main(
        subreddit: str,
        limit: int,
        bootstrap_servers: str,
        topic: str,
        client_id: str,
        client_secret: str,
        user_agent: str,
        dry_run: bool = False,
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
    """
    # Read API credentials from a JSON file
    credentials_manager = APICredentialsManager(client_id=client_id, client_secret=client_secret, user_agent=user_agent)
    credentials_manager.read_from_env()

    # Initialize the Reddit client
    reddit_client = RedditClient(credentials_manager)
    reddit_client.authenticate()

    # Fetch the latest posts from the 'python' subreddit
    posts = reddit_client.fetch_posts(subreddit_name=subreddit, limit=limit)

    if dry_run:
        for post in posts:
            print(f"[DRY RUN] {post}")
    else:
        # Initialize the Kafka producer
        kafka_producer = KafkaMessageProducer(bootstrap_servers=bootstrap_servers, topic=topic)

        # Produce each post to the Kafka topic
        for post in posts:
            json_post = json.dumps(asdict(post))
            kafka_producer.produce_message(json_post)

        # Flush and close the Kafka producer
        kafka_producer.close()

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

    args = parser.parse_args()

    main(
        subreddit=args.subreddit,
        limit=args.limit,
        bootstrap_servers=args.bootstrap_servers,
        topic=args.topic,
        client_id=args.client_id,
        client_secret=args.client_secret,
        user_agent=args.user_agent,
        dry_run=args.dry_run
    )
