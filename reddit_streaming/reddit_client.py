"""Module to interact with the Reddit API using the PRAW library."""
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
import logging

import praw

from reddit_streaming.api_credentials_manager import APICredentialsManager

logger = logging.getLogger(__name__)


@dataclass
class RedditPost:
    """Data class to represent a Reddit post."""
    id: str
    title: str
    author: str
    subreddit: str
    created_utc: float
    url: str
    score: int
    num_comments: int

    def created_utc_to_iso(self):
        """Convert the created_utc timestamp to an ISO-formatted string."""
        return datetime.fromtimestamp(self.created_utc, tz=timezone.utc).isoformat()

    def to_dict(self):
        """Convert the RedditPost instance to a dictionary."""
        return asdict(self)

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
        logger.info("Authenticated Reddit client")

    def fetch_posts(self, subreddit_name: str='all', limit: int=10) -> list[RedditPost]:
        """Fetch the latest posts from a subreddit and return them as a list of RedditPost objects.

        Args:
            subreddit_name (str): The name of the subreddit to fetch posts from. Default is 'all'.
            limit (int): The maximum number of posts to fetch. Default is 10.

        Returns:
            list: A list of dictionaries containing post data.
        """
        if not self.reddit:
            logger.error("Reddit client is not authenticated. Please call authenticate() first.")
            raise Exception("Reddit client is not authenticated. Please call authenticate() first.")

        posts = []
        try:
            subreddit = self.reddit.subreddit(subreddit_name)
            for post in subreddit.new(limit=limit):
                post_data = RedditPost(
                    id=post.id,
                    title=post.title,
                    author=str(post.author),
                    subreddit=post.subreddit.display_name,
                    created_utc=post.created_utc,
                    url=post.url,
                    score=post.score,
                    num_comments=post.num_comments
                )
                posts.append(post_data)
        except Exception as e:
            logger.exception(f"An error occurred while fetching posts from subreddit '{subreddit_name}': {e}")
            raise Exception from e
        return posts
