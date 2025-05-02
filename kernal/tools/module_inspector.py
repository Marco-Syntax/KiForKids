# ./tools/module_inspector.py
# python -m tools.module_inspector

# Summary: This tool inspects all Python modules in the kernel by scanning the ./modules folder and its
# 'stopped' subfolder. It prints the filename, header comments, module type (GUI, API, or MOD), and lists
# all functions defined in the module. For each function, if one or more decorators precede it, those
# decorators are noted alongside the function signature. This tool helps understand module structure and annotations.

import re
from pathlib import Path
from globals.KernalBasics import *

logger = get_logger(__name__)


class ModuleInspector:
    def __init__(self, modules_dir="./modules"):
        self.modules_dir = Path(modules_dir)

    def inspect(self):
        # Gather module files from the modules directory and its "stopped" subfolder.
        file_list = []
        if self.modules_dir.exists():
            for item in self.modules_dir.iterdir():
                if item.is_file() and item.suffix == ".py":
                    file_list.append(item)
                elif item.is_dir() and item.name == "stopped":
                    for stopped_file in item.glob("*.py"):
                        file_list.append(stopped_file)
        # Process each file and print its details.
        content = ""
        for filepath in file_list:
            overview = self.parse_module_file(filepath)
            content += overview + "\n"
            content += "-" * 80 + "\n"
        return content

    def parse_module_file(self, filepath):
        """Parses a module file to extract header comments, module type based on imports,
        and all function definitions with any related decorators."""
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                lines = f.readlines()
        except Exception as e:
            return f"Filename: {filepath.name}\nError reading file: {e}"

        # Extract header comments (all comment lines until the first import statement)
        header_comments = []
        for line in lines:
            if re.match(r"^\s*(import|from)\s+", line):
                break
            if line.strip().startswith("#"):
                header_comments.append(line.strip())
        header_block = "\n".join(header_comments)

        # Determine module type based on imports over the entire file.
        file_content = "".join(lines)
        if re.search(r"(import|from)\s+PyQt5", file_content):
            module_type = "GUI module"
        elif re.search(r"(import|from)\s+FastAPI", file_content):
            module_type = "API module"
        else:
            module_type = "MOD module"

        # List all functions along with any decorators immediately preceding them.
        functions_info = self.get_functions_info(lines)
        functions_lines = "\n".join(["    " + info for info in functions_info]) if functions_info else "    None"

        overview = f"Filename: {filepath.name}\n"
        overview += f"Header Comments:\n{header_block}\n"
        overview += f"Module Type: {module_type}\n"
        overview += f"Functions:\n{functions_lines}\n"
        return overview

    def get_functions_info(self, lines):
        """
        Iterates through lines to find all function definitions.
        For each function, collects any decorators that immediately precede it.
        Returns a list of strings with the function signature and its decorators if available.
        """
        functions = []
        i = 0
        total_lines = len(lines)
        while i < total_lines:
            line = lines[i]
            stripped = line.lstrip()
            # Check if the line is a function definition.
            if stripped.startswith("def "):
                # Backtrack to collect preceding decorators.
                decorators = []
                j = i - 1
                while j >= 0:
                    prev_line = lines[j].strip()
                    if prev_line == "":
                        j -= 1
                        continue
                    if prev_line.startswith("@"):
                        decorators.insert(0, prev_line)
                        j -= 1
                    else:
                        break
                # Clean the function signature by stripping trailing whitespace
                func_signature = stripped.rstrip()
                if decorators:
                    func_info = f"{func_signature}  # Decorators: " + ", ".join(decorators)
                else:
                    func_info = func_signature
                functions.append(func_info)
            i += 1
        return functions


if __name__ == "__main__":
    inspector = ModuleInspector()
    logger.info(inspector.inspect())
