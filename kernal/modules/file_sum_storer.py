# ./modules/stopped/file_sum_storer.py
# Summary: This module reads file paths from a JSON file, identifies which ones are
# not yet summarized, changed or deleted in the file-based database, and processes
# them in chunks of 100 using the file_summarizer tool. After processing each chunk,
# the new summarizations are stored in the database. The module repeats this process every 5 minutes.


import os
import time
import json

# Import tools
from tools.file_database import FileDatabase
from tools.file_summarizer import FileSummarizer
from globals.KernalBasics import *

logger = get_logger(__name__)

# Define paths
FILE_PATHS_JSON = os.path.join(".", "store", "meta", "file_paths.json")
SUM_DB_PATH = os.path.join(".", "store", "file_sums", "sum_db.pkl")
CHUNK_SIZE = 100


def load_file_paths():
    """
    Loads a list of file paths from the FILE_PATHS_JSON file.
    Returns a list of file paths or an empty list in case of error.
    """
    if not os.path.exists(FILE_PATHS_JSON):
        logger.error(f"{FILE_PATHS_JSON} does not exist.")
        return set([])
    try:
        with open(FILE_PATHS_JSON, "r", encoding="utf-8") as f:
            file_paths = json.load(f)
        if not isinstance(file_paths, list):
            logger.error("JSON content is not a list.")
            return set([])
        return set(file_paths)
    except Exception as e:
        logger.error(f"Error loading file paths from {FILE_PATHS_JSON}: {e}")
        return set([])


def process_new_files():
    """
    Loads file paths from the JSON file, determines which ones have not
    been summarized yet (i.e. are missing in the database), and processes
    them in chunks of size CHUNK_SIZE using the FileSummarizer tool.
    After processing each chunk, the summarizations are stored in the database.
    """
    all_file_paths = load_file_paths()
    if not all_file_paths:
        logger.info("No file paths found to process.")
        return

    # Initialize database (non-incremental mode) and get current summaries.
    db = FileDatabase(SUM_DB_PATH, incremental=False)
    current_db_items = db.items()

    # Filter out file paths that are already summarized.
    missing_file_paths = [fp for fp in all_file_paths if fp not in current_db_items]
    # Remove summaries for missing files.
    missing_in_all_files = [fp for fp in current_db_items.keys() if fp not in all_file_paths]
    for missing in missing_in_all_files:
        db.delete(missing)
        logger.info(f"Deleted summarization for {missing} as it is not in the file paths list.")
    # Remove summaries for updated files that it can re-summarize.
    count = 0
    for file_path, summary in current_db_items.items():
        if os.path.exists(file_path):
            modified_time = time.ctime(os.path.getmtime(file_path))
            if summary.startswith("Could not extract content"):
                continue
            if modified_time != summary.split(" | ")[0].replace("Modified at ", ""):
                db.delete(file_path)
                logger.info(f"Deleted due to modification {file_path}. Re-Summarize.")
                if file_path not in missing_in_all_files:
                    missing_file_paths.append(file_path)
                count += 1
    logger.info(f"Deleted {count} summarizations for updated files.")

    if not missing_file_paths:
        logger.info("No new file paths to summarize.")
        return

    logger.info(f"Found {len(missing_file_paths)} new file(s) to summarize.")

    # Process new files in chunks.
    for i in range(0, len(missing_file_paths), CHUNK_SIZE):
        chunk = missing_file_paths[i:i + CHUNK_SIZE]
        logger.info(
            f"Processing chunk {i // CHUNK_SIZE + 1} with {len(chunk)} file(s)."
        )
        try:
            summarizer = FileSummarizer(chunk)
            summaries = summarizer.process()
        except Exception as e:
            logger.error(
                f"Error during summarization for chunk starting at index {i}: {e}"
            )
            continue

        for file_path, summary in summaries.items():
            try:
                db.set(file_path, summary)
                logger.info(f"Stored summarization for {file_path}.")
            except Exception as e:
                logger.error(f"Error storing summary for {file_path}: {e}")

        try:
            db.save()
        except Exception as e:
            logger.error(
                f"Error saving the database after processing chunk starting at index {i}: {e}"
            )


def run(args=None):
    """
    Module entrypoint. Periodically loads file paths from JSON and processes
    new files in chunks of 100 to create and store summarizations using file_summarizer.
    Runs every 5 minutes.
    """
    logger.info("Starting file_sum_storer module. Running every 5 minutes.")
    while True:
        try:
            process_new_files()
        except Exception as e:
            logger.error(f"Unexpected error in processing: {e}")
        time.sleep(301)


if __name__ == "__main__":
    run()
