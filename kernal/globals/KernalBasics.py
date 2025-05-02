# Summary: This file contains the global variables and functions that are used across the project.
import logging
import sys

# --- Custom formatter for consistent module name width and newline handling ---
class ModuleNameFormatter(logging.Formatter):
    def format(self, record):
        # Pad or truncate the name to exactly 20 characters
        if len(record.name) > 20:
            record.name = record.name[:20]
        else:
            record.name = record.name.rjust(20)

        # Format the record
        formatted = super().format(record)

        # Handle newlines in the message by indenting subsequent lines to align with the message start
        if '\n' in formatted:
            lines = formatted.split('\n')
            timestamp_length = len(self._fmt.split('%(message)s')[0].replace('%(name)s', ' ' * 20).replace('%(levelname)s', 'INFO'))
            padding = ' ' * timestamp_length
            return '\n'.join([lines[0]] + [f"{padding}{line}" for line in lines[1:]])
        return formatted

# --- Logging Configuration ---
# Check if logging has already been configured before setting it up
def _is_logging_configured():
    """Check if logging has already been configured by examining existing handlers"""
    return len(logging.root.handlers) > 0

# Configure logging only once
if not _is_logging_configured():
    # Create handler with the custom formatter
    handler = logging.StreamHandler(sys.stdout)
    formatter = ModuleNameFormatter(
        fmt='%(asctime)s [%(levelname)s] [%(name)s] %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    handler.setFormatter(formatter)

    # Configure the root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)
    root_logger.addHandler(handler)

    logging.info("Logging initialized by KernalBasics")


# --- Helper functions for logging ---
def get_logger(name):
    return logging.getLogger(name)



 # Directories to ignore during project scans
SKIP_FOLDERS = {"build", "venv", "target", "dist", ".venv", "__pycache__", ".git", ".idea", ".vscode", ".next", "node_modules", "app_builder", ".DS_Store"}


def is_folder_disbled(folder_name):
    return folder_name in SKIP_FOLDERS