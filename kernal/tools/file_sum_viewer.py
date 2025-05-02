# ./tools/file_sum_viewer.py
# python -m tools.file_sum_viewer

# Summary: This tool opens the pickle-based database located at ./store/file_sums/sum_db.pkl.
# It iterates through all key-value entries and prints them. The code uses the FileDatabase class
# for standardized file access and includes exception handling to manage errors gracefully.

from tools.file_database import FileDatabase
from globals.KernalBasics import *

logger = get_logger(__name__)


class FileSumViewer:
    def __init__(self, db_path="./store/file_sums/sum_db.pkl"):
        self.db_path = db_path

    def display_entries(self, startswith=""):
        content = ""
        try:
            db = FileDatabase(self.db_path, incremental=False)
            items = db.items()
            if not items:
                logger.info("No entries found in the database.")
            else:
                for key, value in items.items():
                    if key.startswith(startswith):
                        logger.info(f"{key}:\n{value}\n\n")
                        content += f"{key}:\n{value}\n\n"
                # Optionally, write the content to a file
                with open("file_sum_viewer_output.txt", "w", encoding="utf-8") as f:
                    f.write(content)
            db.close()
        except Exception as e:
            logger.info(f"An error occurred while reading the database: {e}")
        return content


if __name__ == "__main__":
    viewer = FileSumViewer()
    viewer.display_entries(startswith="/Users/marcogrimme/Repository/homeschool")
