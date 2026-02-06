import os
import re
import argparse
import sys

# Configuration
ROOT_DIR = r"c:\Users\Administrator\source\repos\BalatroOdyssey-not-mine.-fork-i-guess-"
SRC_DIR = os.path.join(ROOT_DIR, "src")
HOOKS_FILE = os.path.join(SRC_DIR, "hooks.lua")
JOKERS_FILE = os.path.join(SRC_DIR, "jokers.lua")

def find_definition(search_term):
    """
    Searches for the definition of an object (Joker, Deck, etc.)
    Pattern: key = 'search_term' or key = "search_term"
    """
    print(f"\n--- Searching for Definition: '{search_term}' ---")
    
    found = False
    
    # Search in all lua files in src
    for root, dirs, files in os.walk(SRC_DIR):
        for file in files:
            if file.endswith(".lua"):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        lines = f.readlines()
                        for i, line in enumerate(lines):
                            if re.search(f"key\\s*=\\s*['\"]{search_term}['\"]", line):
                                print(f"FOUND DEFINITION in {file} at Line {i+1}:")
                                print(f"  {line.strip()}")
                                found = True
                except Exception as e:
                    print(f"Error reading {file}: {e}")
    
    if not found:
        print("No explicit definition (key = '...') found.")

def find_usages(search_term):
    """
    Searches for usages of the term in hooks.lua and jokers.lua
    indicating logic implementation.
    """
    print(f"\n--- Searching for Logic/Usages: '{search_term}' ---")
    
    # Check Hooks (Global Logic)
    if os.path.exists(HOOKS_FILE):
        print(f"\n[Global Hooks] ({os.path.basename(HOOKS_FILE)}):")
        count = 0
        with open(HOOKS_FILE, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            for i, line in enumerate(lines):
                if search_term in line:
                    # Context highlighting
                    context = line.strip()
                    if len(context) > 100: context = context[:100] + "..."
                    print(f"  Line {i+1}: {context}")
                    count += 1
        if count == 0:
            print("  No usages found in hooks.lua.")

    # Check Jokers (Local Logic)
    # Only search jokers.lua if we are looking for something that isn't the joker definition itself
    # But usually we want to see where the key is used in comparisons too.
    if os.path.exists(JOKERS_FILE):
        print(f"\n[Joker Logic] ({os.path.basename(JOKERS_FILE)}):")
        count = 0
        with open(JOKERS_FILE, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            for i, line in enumerate(lines):
                # Avoid re-printing the definition key line if possible, but simplicity is better
                if search_term in line:
                     # Check if it's the definition line again, skip strict definition
                    if re.search(f"key\\s*=\\s*['\"]{search_term}['\"]", line):
                        continue
                        
                    context = line.strip()
                    if len(context) > 100: context = context[:100] + "..."
                    print(f"  Line {i+1}: {context}")
                    count += 1
        if count == 0:
            print("  No logic usages found in jokers.lua (excluding definition).")

def main():
    parser = argparse.ArgumentParser(description="Find definition and logic for a Balatro ID.")
    parser.add_argument("id", help="The ID to search for (e.g., j_singularity_solitary, timeline)")
    args = parser.parse_args()
    
    find_definition(args.id)
    find_usages(args.id)

if __name__ == "__main__":
    main()
