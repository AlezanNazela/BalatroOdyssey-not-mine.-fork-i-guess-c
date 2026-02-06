import os
import re

ROOT_DIR = r"c:\Users\Administrator\source\repos\BalatroOdyssey-not-mine.-fork-i-guess-"
SRC_DIR = os.path.join(ROOT_DIR, "src")
OUTPUT_FILE = os.path.join(ROOT_DIR, ".agent", "skills", "codebase_lookup", "resources", "index.md")

def index_jokers():
    jokers_file = os.path.join(SRC_DIR, "jokers.lua")
    if not os.path.exists(jokers_file):
        return []
    
    results = []
    # Pattern to find SMODS.Joker and the key
    # It might be across multiple lines
    with open(jokers_file, 'r', encoding='utf-8') as f:
        content = f.read()
        # Find matches for SMODS.Joker({ ... key = '...'
        matches = re.finditer(r"SMODS\.Joker\(\{.*?key\s*=\s*'([^']+)'", content, re.DOTALL)
        for match in matches:
            key = match.group(1)
            line_no = content.count('\n', 0, match.start()) + 1
            results.append(f"- **Joker**: `{key}` | [Line {line_no}](file:///{jokers_file.replace('\\', '/')}/#L{line_no})")
    return results

def index_spectrals():
    consumables_file = os.path.join(SRC_DIR, "consumables.lua")
    if not os.path.exists(consumables_file):
        return []

    results = []
    with open(consumables_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
        # Look for spectral logic table entries: [ID] = function(card, area, copier) -- Name
        for i, line in enumerate(lines):
            match = re.search(r"\[(\d+)\]\s*=\s*function\(.*?\)\s*--\s*(.*)", line)
            if match:
                id_num = match.group(1)
                name = match.group(2).strip()
                line_no = i + 1
                results.append(f"- **Spectral**: {name} (`spectral_{id_num}`) | [Line {line_no}](file:///{consumables_file.replace('\\', '/')}/#L{line_no})")
    return results

def index_planets():
    consumables_file = os.path.join(SRC_DIR, "consumables.lua")
    if not os.path.exists(consumables_file):
        return []

    results = []
    with open(consumables_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
        # Look for planets table entries: { id = X, key = "planet_X", name = "...", hand = "..." }
        for i, line in enumerate(lines):
            match = re.search(r"\{.*?id\s*=\s*(\d+).*?key\s*=\s*\"([^\"]+)\".*?name\s*=\s*\"([^\"]+)\".*?hand\s*=\s*\"([^\"]+)\"", line)
            if match:
                id_num = match.group(1)
                key = match.group(2)
                name = match.group(3)
                hand = match.group(4)
                line_no = i + 1
                results.append(f"- **Planet**: {name} (`{key}`) | Hand: `{hand}` | [Line {line_no}](file:///{consumables_file.replace('\\', '/')}/#L{line_no})")
    return results

def index_decks():
    decks_file = os.path.join(SRC_DIR, "decks.lua")
    if not os.path.exists(decks_file):
        return []
    
    results = []
    with open(decks_file, 'r', encoding='utf-8') as f:
        content = f.read()
        matches = re.finditer(r"SMODS\.Back\(\{.*?key\s*=\s*\"([^\"]+)\"", content, re.DOTALL)
        for match in matches:
            key = match.group(1)
            line_no = content.count('\n', 0, match.start()) + 1
            results.append(f"- **Deck**: `{key}` | [Line {line_no}](file:///{decks_file.replace('\\', '/')}/#L{line_no})")
    return results

def index_vouchers():
    vouchers_file = os.path.join(SRC_DIR, "vouchers.lua")
    if not os.path.exists(vouchers_file):
        return []
    
    results = []
    with open(vouchers_file, 'r', encoding='utf-8') as f:
        content = f.read()
        matches = re.finditer(r"SMODS\.Voucher\(\{.*?key\s*=\s*\"([^\"]+)\"", content, re.DOTALL)
        for match in matches:
            key = match.group(1)
            line_no = content.count('\n', 0, match.start()) + 1
            results.append(f"- **Voucher**: `{key}` | [Line {line_no}](file:///{vouchers_file.replace('\\', '/')}/#L{line_no})")
    return results

def main():
    print("Indexing codebase...")
    all_indices = []
    
    all_indices.append("# Balatro Odyssey Codebase Index\n")
    
    all_indices.append("## Spectrals")
    all_indices.extend(index_spectrals())
    
    all_indices.append("\n## Planets")
    all_indices.extend(index_planets())
    
    all_indices.append("\n## Decks")
    all_indices.extend(index_decks())
    
    all_indices.append("\n## Vouchers")
    all_indices.extend(index_vouchers())
    
    all_indices.append("\n## Jokers")
    jokers = index_jokers()
    all_indices.extend(jokers)
    
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write("\n".join(all_indices))
    
    print(f"Index generated at {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
