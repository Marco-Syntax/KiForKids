# ./tools/json_file_tree.py
# python -m tools.json_file_tree
# Summary: Dieses Tool baut rekursiv einen JSON-File-Tree aus einem Startverzeichnis (default ".") auf.
# Es schließt versteckte Dateien/Ordner sowie im Root die Ordner "./store" und "./website" aus und schließt
# außerdem alle "__pycache__"-Ordner in allen Ebenen aus. Der resultierende Baum ist alphabetisch sortiert
# – zuerst Ordner, dann Dateien.

import os
import json
from globals.KernalBasics import *

logger = get_logger(__name__)


class JsonFileTree:
    def __init__(self):
        # Ordner, die stets ausgeschlossen werden, egal in welcher Tiefe
        self.always_excluded_dirs = {"__pycache__"}
        # Ordner, die nur im Root-Verzeichnis ausgeschlossen werden
        self.root_excluded_dirs = {"store", "website"}

    def build_tree(self, current_path=".", depth=0, parent_path="."):
        """
        Rekursive Methode, die den File-Tree als verschachteltes Dictionary erstellt.
        Versteckte Dateien/Ordner (beginnen mit '.') werden übersprungen.
        Im Root werden 'store' und 'website' ausgeschlossen, während '__pycache__' in allen Ebenen ausgeschlossen wird.
        Jeder Eintrag enthält jetzt auch ein 'file_path' Attribut mit dem vollen Pfad relativ zum Startverzeichnis.
        """
        if os.path.isdir(current_path):
            node_name = os.path.basename(os.path.abspath(current_path)) if depth > 0 else os.path.abspath(current_path)

            # Compute relative file path
            rel_path = parent_path if depth == 0 else os.path.join(parent_path, os.path.basename(current_path))

            tree = {
                "name": node_name,
                "type": "folder",
                "file_path": rel_path,  # Add the file_path attribute
                "children": []
            }

            try:
                entries = os.listdir(current_path)
            except Exception:
                return tree

            filtered_entries = []
            for entry in entries:
                if entry.startswith(".") or entry.startswith("__"):
                    continue
                # Schließe alle __pycache__-Ordner aus, unabhängig von der Tiefe
                if entry in self.always_excluded_dirs:
                    continue
                # Schließe "store" und "website" nur im Root-Verzeichnis aus
                if depth == 0 and entry in self.root_excluded_dirs:
                    continue
                filtered_entries.append(entry)

            # Sortiere alphabetisch die Ordner und Dateien getrennt
            folders = sorted([e for e in filtered_entries if os.path.isdir(os.path.join(current_path, e))])
            files = sorted([e for e in filtered_entries if os.path.isfile(os.path.join(current_path, e))])
            sorted_entries = folders + files

            for entry in sorted_entries:
                full_path = os.path.join(current_path, entry)
                if os.path.isdir(full_path):
                    child = self.build_tree(full_path, depth=depth+1, parent_path=rel_path)
                    tree["children"].append(child)
                else:
                    # For files, also include file_path
                    file_path = os.path.join(rel_path, entry)
                    tree["children"].append({
                        "name": entry,
                        "type": "file",
                        "file_path": file_path  # Add the file_path attribute
                    })
            return tree
        else:
            basename = os.path.basename(current_path)
            file_path = os.path.join(parent_path, basename)
            return {
                "name": basename,
                "type": "file",
                "file_path": file_path  # Add the file_path attribute
            }

    def to_json(self, start_path="."):
        """
        Erstellt den File-Tree ab dem start_path und gibt ihn als formatierten JSON-String zurück.
        """
        tree = self.build_tree(start_path)
        return json.dumps(tree, indent=4)

if __name__ == "__main__":
    tool = JsonFileTree()
    json_tree = tool.to_json(".")
    logger.info(json_tree)