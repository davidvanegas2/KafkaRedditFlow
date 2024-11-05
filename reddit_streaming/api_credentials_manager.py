"""Classes to interact with the Reddit API and fetch posts from a subreddit."""

import os
from dotenv import load_dotenv


class APICredentialsManager:
    """Class to manage API credentials for Reddit API."""

    def __init__(self, client_id=None, client_secret=None, user_agent=None):
        """Initialize the API credentials.

        Args:
            client_id (str): The client ID for the Reddit API.
            client_secret (str): The client secret for the Reddit API.
            user_agent (str): The user agent for the Reddit API.
        """
        self.client_id = client_id
        self.client_secret = client_secret
        self.user_agent = user_agent

    def get_client_id(self):
        """Return the client ID."""
        return self.client_id

    def get_client_secret(self):
        """Return the client secret."""
        return self.client_secret

    def get_user_agent(self):
        """Return the user agent."""
        return self.user_agent

    def read_from_env(self):
        """Read API credentials from environment variables."""
        load_dotenv()
        self.client_id = os.getenv('REDDIT_CLIENT_ID')
        self.client_secret = os.getenv('REDDIT_CLIENT_SECRET')
        self.user_agent = os.getenv('REDDIT_USER_AGENT')
