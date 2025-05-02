# ./tools/project_reflector.py
# python -m tools.project_reflector
# Summary: This tool scans all Python files in the project recursively, reads their content,
# and builds a meta prompt for LLMs. After adding each file's content, it also appends the
# complete project structure (using the existing ProjectStructure tool) to facilitate project reflection.

import os
from tools.project_structure import ProjectStructure
from globals.KernalBasics import *

logger = get_logger(__name__)


class ProjectReflector:

    def __init__(self, project_root="."):
        self.project_root = os.path.abspath(project_root)
        self.project_structure = ProjectStructure()

    def find_python_files(self):
        """
        Walk through the project directory and return a list of all Python file paths.
        """
        python_files = []
        for root, dirs, files in os.walk(self.project_root):
            # Filter out ignored directories
            dirs[:] = [d for d in dirs if not is_folder_disbled(d)]
            for file in files:
                if file.endswith(".py"):
                    file_path = os.path.join(root, file)
                    # Ensure the file is within the project root
                    python_files.append(os.path.relpath(file_path, self.project_root))
        return python_files

    def read_file_content(self, file_path):
        """
        Read and return the content of a file. If any error occurs, return an error message comment.
        """
        full_path = os.path.join(self.project_root, file_path)
        try:
            with open(full_path, "r", encoding="utf-8") as f:
                return f.read()
        except Exception as e:
            return f"// Error reading {file_path}: {e}"

    def build_meta_prompt(self):
        """
        Build a meta prompt string that aggregates all Python file contents and the project structure.
        """
        meta_prompt = "# META PROMPT FOR PROJECT REFLECTION\n\n"
        meta_prompt += "## Python Files Contents:\n\n"
        python_files = self.find_python_files()
        if not python_files:
            meta_prompt += "// No Python files found in the project.\n"
        else:
            for file_path in python_files:
                file_content = self.read_file_content(file_path)
                meta_prompt += f"## FILE: {file_path}\n"
                meta_prompt += "```\n" + file_content + "\n```\n\n"
        meta_prompt += "## Project Structure:\n\n"
        meta_prompt += self.project_structure.print_file_structure(self.project_root)
        return meta_prompt

    def reflect(self):
        """
        Build and return the complete meta prompt with all project details.
        """
        return self.build_meta_prompt()


if __name__ == "__main__":
    reflector = ProjectReflector()
    meta_prompt = reflector.reflect()
    # Output the result to the console; optionally, save to a file if needed.
    logger.info(meta_prompt)
    with open("meta_prompt.txt", "w", encoding="utf-8") as f:
        f.write(meta_prompt)
