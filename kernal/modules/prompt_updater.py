# ./modules/prompt_updater.py

import os
import time
from pathlib import Path
from globals.KernalBasics import *
from tools.project_structure import ProjectStructure
from tools.file_database import FileDatabase

logger = get_logger(__name__)

def get_file_summaries():
    """Load file summaries from the database."""
    try:
        # Initialize the file database
        db_path = os.path.join("store", "file_sums", "sum_db.pkl")
        
        # Load summaries from database
        db = FileDatabase(db_path, incremental=False)
        summaries = db.items()
        
        # Format summaries for inclusion in the prompt
        formatted_summaries = "## FILE SUMMARIES:\n\n"
        for file_path, summary in summaries.items():
            if "kernal/" in file_path:
                continue
            # Format the file path and summary
            formatted_summaries += f"### {file_path}\n{summary}\n\n"
        
        db.close()
        return formatted_summaries
    except Exception as e:
        logger.error(f"Error loading file summaries: {e}")
        return "## FILE SUMMARIES:\n\nError loading summaries\n\n"


def read_file_content(file_path):
    """Read content from a file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return file.read()
    except Exception as e:
        logger.error(f"Error reading file {file_path}: {e}")
        return ""

def update_prompt_file():
    """Update the base prompt file with project structure and dependencies."""
    # Define file paths
    kernal_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    repo_dir = os.path.dirname(kernal_dir)
    
    basic_prompt_path = os.path.join(kernal_dir, "store", "prompts", "basic_prompt.txt")
    base_prompt_path = os.path.join(kernal_dir, "../base_prompt.gpt")
    pubspec_path = os.path.join(repo_dir, "frontend", "pubspec.yaml")
    
    # Read basic prompt content
    basic_prompt_content = read_file_content(basic_prompt_path)
    
    # Get project structure
    project_structure = ProjectStructure()
    structure_content = project_structure.print_file_structure(repo_dir)
    
    # Read pubspec.yaml content
    pubspec_content = read_file_content(pubspec_path)
    
    # Combine all content
    final_content = (
        basic_prompt_content + 
        "\n\n## PROJECT STRUCTURE:\n\n" + structure_content + "\n\n" +
        get_file_summaries() + "## DEPENDENCIES:\n\n" + pubspec_content
    )
    
    # Write to base_prompt.gpt
    try:
        with open(base_prompt_path, 'w', encoding='utf-8') as file:
            file.write(final_content)
        logger.info(f"Successfully updated base_prompt.gpt at {time.strftime('%Y-%m-%d %H:%M:%S')}")
    except Exception as e:
        logger.error(f"Error writing to base_prompt.gpt: {e}")

def run(args=None):
    """Run the prompt updater module."""
    logger.info("Starting Prompt Updater module")
    
    try:
        while True:
            update_prompt_file()
            time.sleep(15)  # Update every 15 seconds
    except KeyboardInterrupt:
        logger.info("Prompt Updater module stopped by user")
    except Exception as e:
        logger.error(f"Error in Prompt Updater module: {e}")
