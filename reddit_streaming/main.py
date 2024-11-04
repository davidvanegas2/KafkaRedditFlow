"""Main module of the program."""

from reddit_streaming.api_credentials_manager import APICredentialsManager
from reddit_streaming.reddit_client import RedditClient
from reddit_streaming.kafka_producer import KafkaProducer

def main():
    """Main entry point of the program."""
    # Read API credentials from a JSON file
    credentials_manager = APICredentialsManager()
    credentials_manager.read_from_json('reddit_credentials.json')

    # Initialize the Reddit client
    reddit_client = RedditClient(credentials_manager)
    reddit_client.authenticate()

    # Initialize the Kafka producer
    kafka_producer = KafkaProducer(bootstrap_servers='localhost:9092', topic='reddit_posts')

    # Fetch the latest posts from the 'python' subreddit
    posts = reddit_client.fetch_posts(subreddit_name='python', limit=10)

    # Produce each post to the Kafka topic
    for post in posts:
        kafka_producer.produce_message(str(post))

    # Flush and close the Kafka producer
    kafka_producer.close()

if __name__ == "__main__":
    main()
