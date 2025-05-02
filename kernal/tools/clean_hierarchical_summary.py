# ./tools/clean_hierarchical_summary.py
# python -m tools.clean_hierarchical_summary

# Summary: This tool opens the 'hierarchical_summary.txt' file in the store/meta folder,
# removes all lines that start with "  /",
# and writes the filtered content to 'summery_base_prompt.txt' in the same folder.

import os
from globals.KernalBasics import *

logger = get_logger(__name__)


class CleanHierarchicalSummary:
    def __init__(self):
        self.input_file = os.path.join("store", "meta", "hierarchical_summary.txt")
        self.output_file = os.path.join("store", "meta", "summery_base_prompt.txt")

    def process(self):
        if not os.path.exists(self.input_file):
            logger.info(f"Input file '{self.input_file}' does not exist.")
            return

        try:
            with open(self.input_file, "r", encoding="utf-8") as infile:
                lines = infile.readlines()
            # Remove lines starting with "  /"
            filtered_lines = [line for line in lines if not line.startswith("  /")]
            os.makedirs(os.path.dirname(self.output_file), exist_ok=True)
            with open(self.output_file, "w", encoding="utf-8") as outfile:
                outfile.writelines(filtered_lines)
            logger.info(f"Filtered content successfully written to '{self.output_file}'.")
        except Exception as e:
            logger.info(f"Error processing files: {e}")


if __name__ == "__main__":
    tool = CleanHierarchicalSummary()
    tool.process()
