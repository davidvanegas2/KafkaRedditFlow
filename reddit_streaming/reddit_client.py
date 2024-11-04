"""Module to interact with the Reddit API using the PRAW library."""
import praw

from reddit_streaming.api_credentials_manager import APICredentialsManager


class RedditClient:
    """Class to interact with the Reddit API."""

    def __init__(self, credentials_manager: APICredentialsManager):
        """Initialize the Reddit client with the provided credentials manager.

        Args:
            credentials_manager (APICredentialsManager): The credentials manager to use for authentication
        """
        self.credentials_manager = credentials_manager
        self.reddit = None

    def authenticate(self):
        """Authenticate the Reddit client using the provided credentials."""
        self.reddit = praw.Reddit(
            client_id=self.credentials_manager.get_client_id(),
            client_secret=self.credentials_manager.get_client_secret(),
            user_agent=self.credentials_manager.get_user_agent()
        )

    def fetch_posts(self, subreddit_name: str='all', limit: int=10):
        """Fetch the latest posts from a subreddit and return them as a list of dictionaries.

        Args:
            subreddit_name (str): The name of the subreddit to fetch posts from. Default is 'all'.
            limit (int): The maximum number of posts to fetch. Default is 10.

        Returns:
            list: A list of dictionaries containing post data.
        """
        if not self.reddit:
            raise Exception("Reddit client is not authenticated. Please call authenticate() first.")

        posts = []
        try:
            subreddit = self.reddit.subreddit(subreddit_name)
            for post in subreddit.new(limit=limit):
                post_data = {
                    'id': post.id,
                    'title': post.title,
                    'author': str(post.author),
                    'subreddit': post.subreddit.display_name,
                    'created_utc': post.created_utc,
                    'url': post.url,
                    'score': post.score,
                    'num_comments': post.num_comments
                }
                posts.append(post_data)
        except Exception as e:
            print(f"An error occurred: {e}")
        return posts
