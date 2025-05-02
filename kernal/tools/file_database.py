# ./tools/file_database.py
# python -m tools.file_database
# Summary: This script provides a FileDatabase class that can be used to store key-value pairs in a file.
# It supports both incremental and non-incremental writes. The class uses a lock
# to ensure thread safety and provides methods to set, get, delete, and list items.

import os
import pickle
import threading
import shelve
from globals.KernalBasics import *

logger = get_logger(__name__)


class FileDatabase:
    def __init__(self, db_file, incremental=False):
        self.db_file = db_file
        self.incremental = incremental
        self.lock = threading.Lock()

        # Ensure the directory exists
        self._ensure_directory_exists()

        if self.incremental:
            # Use shelve for incremental writes
            self.db = shelve.open(self.db_file, writeback=True)
        else:
            self.data = {}
            self._load_db()

    def _ensure_directory_exists(self):
        """Ensure the directory for the database file exists."""
        directory = os.path.dirname(self.db_file)
        if directory and not os.path.exists(directory):
            try:
                os.makedirs(directory, exist_ok=True)
                logger.info(f"Created directory: {directory}")
            except Exception as e:
                logger.error(f"Failed to create directory {directory}: {str(e)}")

    def _load_db(self):
        with self.lock:
            if os.path.exists(self.db_file):
                try:
                    with open(self.db_file, "rb") as f:
                        self.data = pickle.load(f)
                except Exception:
                    # Handle exceptions or logging if necessary
                    self.data = {}

    def save(self):
        if self.incremental:
            with self.lock:
                self.db.sync()
        else:
            with self.lock:
                try:
                    with open(self.db_file, "wb") as f:
                        pickle.dump(self.data, f, protocol=pickle.HIGHEST_PROTOCOL)
                except Exception:
                    # Handle exceptions or logging if necessary
                    pass

    def set(self, key, value):
        if self.incremental:
            with self.lock:
                self.db[key] = value
                self.db.sync()
        else:
            with self.lock:
                self.data[key] = value
            self.save()

    def get(self, key, default=None):
        if self.incremental:
            with self.lock:
                return self.db.get(key, default)
        else:
            with self.lock:
                return self.data.get(key, default)

    def delete(self, key):
        if self.incremental:
            with self.lock:
                if key in self.db:
                    del self.db[key]
                self.db.sync()
        else:
            with self.lock:
                if key in self.data:
                    del self.data[key]
            self.save()

    def items(self):
        if self.incremental:
            with self.lock:
                return dict(self.db)
        else:
            with self.lock:
                return dict(self.data)

    def close(self):
        if self.incremental:
            self.db.close()


# Example usage when running the file directly
if __name__ == "__main__":
    db = FileDatabase(
        "./store/file_sums/sum_db.pkl", incremental=False
    )  # Using persistent pickle file
    items = db.items()
    for key, value in items.items():
        logger.info(f"{key}: {value}")
