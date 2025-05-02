# ./tools/project_structure.py
# python -m tools.project_structure
# Summary: A simple tool to print the project file structure.

import os
from globals.KernalBasics import *

logger = get_logger(__name__)


class ProjectStructure:

    def print_file_structure(self, startpath="."):
        logger.info("Project File Structure:")
        content = ""
        for root, dirs, files in os.walk(startpath):
            if (
                ".git" in root
                or "__pycache__" in root
                or "venv" in root
                or "dev" in root
                or ".next" in root
                or "node_modules" in root
                or "app_builder" in root
                or "kernal" in root
                or "build" in root
                or ".dart_tool" in root
                or "target" in root
            ):
                continue
            level = root.replace(startpath, "").count(os.sep)
            indent = " " * 2 * level
            content += f"{indent}{os.path.basename(root)}/\n"
            subindent = " " * 2 * (level + 1)
            for f in files:
                content += f"{subindent}{f}\n"
        return content


# For standalone execution
if __name__ == "__main__":
    ps = ProjectStructure()
    content = ps.print_file_structure()
    logger.info(content)
    # print(content)
