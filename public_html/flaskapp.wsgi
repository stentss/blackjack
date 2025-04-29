import sys
import logging

# Add your backend folder to the path so we can import app.py
sys.path.insert(0, "/home/rhnguyen/backend")

# Optional: for debugging
logging.basicConfig(stream=sys.stderr)

# Import your Flask app from app.py
from app import app as application
