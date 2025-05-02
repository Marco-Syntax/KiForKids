# ./tools/tool_inspector.py
# python -m tools.tool_inspector

# Summary: This tool iterates through the tools folder and builds a usage overview string for each tool file.
# It extracts the header comments (all comments before the first import) and parses each class with its functions,
# including function definitions with parameters and return type (if annotated).

import os
import re
from pathlib import Path
from globals.KernalBasics import *

logger = get_logger(__name__)


class ToolInspector:

    def parse_tool_file(self, filepath, only_header=False):
        """
        Parses a single tool file to extract its header comments and class/function definitions.
        The header comments are all the leading comments until the first 'import' statement.
        For each class, it extracts its name and any function definitions inside it, along with their parameters
        and optional return types.
        """
        with open(filepath, "r", encoding="utf-8") as f:
            lines = f.readlines()

        # Extract header comments until the first import statement
        header_comments = []
        for line in lines:
            if re.match(r"^\s*import\s+", line):
                break
            if line.strip().startswith("#"):
                header_comments.append(line.strip())
        header_block = "\n".join(header_comments)
        if only_header:
            return header_block

        # Use regex patterns to find class definitions and function definitions inside classes.
        class_pattern = re.compile(r"^class\s+(\w+)\b")
        func_pattern = re.compile(
            r"^\s+def\s+(\w+)\(([^)]*)\)(?:\s*->\s*([\w\[\],. ]+))?:"
        )

        class_overviews = {}
        current_class = None

        for line in lines:
            # Check for class definition
            class_match = class_pattern.match(line)
            if class_match:
                current_class = class_match.group(1)
                class_overviews[current_class] = []
                continue

            # If in a class, check for function definitions with additional indentation
            if current_class:
                func_match = func_pattern.match(line)
                if func_match:
                    func_name = func_match.group(1)
                    params = func_match.group(2).strip()
                    return_type = func_match.group(3)
                    if return_type:
                        signature = f"def {func_name}({params}) -> {return_type}:"
                    else:
                        signature = f"def {func_name}({params}):"
                    class_overviews[current_class].append(signature)

        # Build the overview string for the file
        file_overview = header_block + "\n"
        for cls_name, functions in class_overviews.items():
            file_overview += f"\n{cls_name}\n"
            for func_def in functions:
                file_overview += f"  {func_def}\n"

        return file_overview.strip()

    def build_usage_structure(self, only_header=False):
        """
        Iterates through all Python files in the tools folder (excluding __init__.py and itself),
        parses each file to extract its usage structure, and builds a complete overview string.
        """
        base_dir = Path(__file__).parent  # Directory: tools folder
        overview_str = ""
        for file in os.listdir(base_dir):
            # Process only Python files, skip __init__.py and this file itself.
            if file.endswith(".py") and file not in [
                "__init__.py",
                os.path.basename(__file__),
            ]:
                filepath = base_dir / file
                try:
                    file_overview = self.parse_tool_file(filepath, only_header)
                    overview_str += f"\nFile: {file}\n{file_overview}\n"
                except Exception as e:
                    overview_str += f"\nFile: {file}\nError parsing file: {e}\n"
        return overview_str.strip()


# For standalone execution
if __name__ == "__main__":
    usage_structure = ToolInspector().build_usage_structure()
    logger.info(usage_structure)
