# ./modules/file_tree_builder.py
# Summary: This module scans folder paths from the tree_builder.json configuration file
# and builds a file tree structure. It writes a textual tree representation to
# "./store/meta/file_trees.txt", stores a JSON file "./store/meta/file_paths.json" with
# all file paths (files only), and now also writes a JSON file "./store/meta/folder_pathes.json"
# containing all unique folder paths encountered during the scan. The tree includes
# creation dates when applicable and updates every 5 minutes.

import os
import json
import time
from globals.KernalBasics import *

OUTPUT_FILE = os.path.join(".", "store", "meta", "file_trees.txt")
OUTPUT_JSON = os.path.join(".", "store", "meta", "file_paths.json")
OUTPUT_FOLDER_JSON = os.path.join(".", "store", "meta", "folder_pathes.json")
TREE_BUILDER_CONFIG = os.path.join(
    os.path.dirname(__file__), "..", "config", "tree_builder.json"
)

logger = get_logger(__name__)

def is_dir_excluded(path):
    base = os.path.basename(path)
    if base.startswith("."):
        return True
    if (
        "__pycache__" in path
        or "venv" in path
        or "dist" in path
        or "build" in path
        or "target" in path
        or ".next" in path
        or "node_modules" in path
    ):
        return True
    if "ios/Pods" in path or "ios/Runner" in path:
        return True
    if "05 Videos" in path or "02 its'R creator von Bastian" in path:
        return True
    if "kernal/store" in path or "kernal/pipes" in path:
        return True
    return False


def scan_files(path):
    # Return True if the file extension is one of the supported file types.
    supported_extensions = (
        ".py",
        ".dart",
        ".json",
        ".yaml",
        ".txt",
        ".md",
        ".java",
        ".cpp",
        ".docx",
        ".pdf",
        ".xlsx",
        ".css",
        ".html",
        ".js",
        ".groovy",
        ".toml",
        ".xml",
        ".yml",
        ".csv",
        ".sh",
        ".tsx",
    )
    if path.endswith(".freezed.dart"):
        return False
    return path.endswith(supported_extensions)


def build_tree_text(root, level=0, include_date=True, file_paths=None, folder_set=None):
    if file_paths is None:
        file_paths = []
    if folder_set is None:
        folder_set = set()

    abs_root = os.path.abspath(root)
    folder_set.add(abs_root)

    indent = "  " * level
    date_text = ""
    if include_date:
        try:
            creation_date = time.ctime(os.path.getmtime(root))
        except Exception as e:
            logger.error(f"Error getting creation date for {root}: {e}")
            creation_date = "N/A"
        date_text = f" ({creation_date})"

    if level == 0:
        tree_text = f"{abs_root}/{date_text}\n"
    else:
        tree_text = f"{indent}{os.path.basename(root)}/{date_text}\n"

    try:
        entries = sorted(os.listdir(root))
    except Exception as e:
        logger.error(f"Error listing directory {root}: {e}")
        return tree_text

    for entry in entries:
        entry_path = os.path.join(root, entry)
        if not scan_files(entry) and not os.path.isdir(entry_path):
            continue
        if is_dir_excluded(entry_path):
            continue
        if os.path.isdir(entry_path):
            tree_text += build_tree_text(
                entry_path, level + 1, include_date, file_paths, folder_set
            )
        else:
            abs_entry_path = os.path.abspath(entry_path)
            # Append file path to list (files only)
            file_paths.append(abs_entry_path)
            file_date_text = ""
            if include_date:
                try:
                    entry_creation_date = time.ctime(os.path.getmtime(entry_path))
                except Exception as e:
                    logger.error(f"Error getting creation date for {entry_path}: {e}")
                    entry_creation_date = "N/A"
                file_date_text = f" ({entry_creation_date})"
            tree_text += f"{'  ' * (level+1)}{entry}{file_date_text}\n"
    return tree_text


def load_tree_builder_config():
    """
    Loads configuration from TREE_BUILDER_CONFIG.
    Expects JSON structure:
    {
      "file_paths": [
           ["/path/to/folder", true],
           "/path/to/another_folder"
      ]
    }
    Returns the configuration dictionary.
    """
    try:
        with open(TREE_BUILDER_CONFIG, "r") as f:
            config = json.load(f)
        logger.info(f"Loaded tree builder config: {config}")
        return config
    except Exception as e:
        logger.error(f"Failed to load config {TREE_BUILDER_CONFIG}: {e}")
        return {}


def update_file_tree():
    """
    Builds the file tree for each folder specified in the configuration and writes
    the combined text to OUTPUT_FILE. Also stores a JSON file OUTPUT_JSON with a list
    of all file paths (files only) and a JSON file OUTPUT_FOLDER_JSON with all unique folder paths.
    Each folder may specify its own 'include_creation_date' flag if defined as a list with [folder_path, flag].
    Otherwise, the default flag True is used.
    """
    config = load_tree_builder_config()
    folder_entries = config.get("file_paths", [])

    if not folder_entries:
        logger.error("No folder paths found in the configuration.")
        return

    output_text = ""
    all_file_paths = []
    all_folder_paths = set()

    for entry in folder_entries:
        # Check if entry is a list containing folder path and boolean flag.
        if isinstance(entry, list):
            if len(entry) != 2:
                logger.error(
                    f"Invalid folder entry format (expected [path, boolean]): {entry}"
                )
                continue
            folder, include_date = entry[0], entry[1]
        else:
            folder = entry
            include_date = True  # default if not specified

        # Ensure folder is a string.
        if not isinstance(folder, str):
            logger.error(f"Folder path is not a string: {folder}")
            continue

        if os.path.exists(folder) and os.path.isdir(folder):
            logger.info(
                f"Building file tree for folder: {folder} with include_date={include_date}"
            )
            abs_folder = os.path.abspath(folder)
            tree_text = build_tree_text(
                abs_folder,
                include_date=include_date,
                file_paths=all_file_paths,
                folder_set=all_folder_paths,
            )
            output_text += tree_text + "\n"
        else:
            logger.error(f"Folder does not exist or is not a directory: {folder}")

    # Ensure the output directory exists.
    output_dir = os.path.dirname(OUTPUT_FILE)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    try:
        with open(OUTPUT_FILE, "w") as f:
            f.write(output_text)
        logger.info(f"File tree saved successfully to {OUTPUT_FILE}.")
    except Exception as e:
        logger.error(f"Failed to write file tree to {OUTPUT_FILE}: {e}")

    # Write the list of file paths to the JSON file OUTPUT_JSON.
    try:
        with open(OUTPUT_JSON, "w") as f:
            json.dump(all_file_paths, f, indent=2)
        logger.info(f"File paths saved successfully to {OUTPUT_JSON}.")
    except Exception as e:
        logger.error(f"Failed to write file paths to {OUTPUT_JSON}: {e}")

    # Write the list of unique folder paths to OUTPUT_FOLDER_JSON.
    try:
        with open(OUTPUT_FOLDER_JSON, "w") as f:
            json.dump(sorted(list(all_folder_paths)), f, indent=2)
        logger.info(f"Folder paths saved successfully to {OUTPUT_FOLDER_JSON}.")
    except Exception as e:
        logger.error(f"Failed to write folder paths to {OUTPUT_FOLDER_JSON}: {e}")


def run(args=None):
    """
    Module entrypoint. Updates the file tree, file paths JSON, and folder paths JSON every 5 minutes.
    """
    logger.info(
        "Starting file_tree_builder module. Updating file tree every 5 minutes."
    )
    while True:
        try:
            update_file_tree()
        except Exception as e:
            logger.error(f"Unexpected error during file tree update: {e}")
        time.sleep(887)


if __name__ == "__main__":
    run()
